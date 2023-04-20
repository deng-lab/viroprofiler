/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    VALIDATE INPUTS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

def summary_params = NfcoreSchema.paramsSummaryMap(workflow, params)

// Validate input parameters
WorkflowViroprofiler.initialise(params, log)

// TODO nf-core: Add all file path parameters for the pipeline to the list below
// Check input path parameters to see if they exist
def checkPathParamList = [ params.multiqc_config ]
for (param in checkPathParamList) { if (param) { file(param, checkIfExists: true) } }


/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    CONFIG FILES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

ch_multiqc_config        = file("$projectDir/assets/multiqc_config.yml", checkIfExists: true)
ch_multiqc_custom_config = params.multiqc_config ? Channel.fromPath(params.multiqc_config) : Channel.empty()

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT LOCAL MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// SUBWORKFLOW: Consisting of a mix of local and nf-core/modules
//
include { INPUT_CHECK             } from '../subworkflows/local/input_check'
include { vMAG_PHAMB; vMAG_VRHYME } from '../subworkflows/local/vMAG'
include { SETUP } from '../subworkflows/local/init'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT NF-CORE MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// MODULE: Installed directly from nf-core/modules
//


include { FASTQC                       } from '../modules/nf-core/modules/fastqc/main'
include { MULTIQC                      } from '../modules/nf-core/modules/multiqc/main'
include { CUSTOM_DUMPSOFTWAREVERSIONS  } from '../modules/nf-core/modules/custom/dumpsoftwareversions/main'
include { FASTP                        } from '../modules/nf-core/modules/fastp/main'
include { SPADES                       } from '../modules/nf-core/modules/spades/main'
include { BBMAP_ALIGN                  } from '../modules/nf-core/modules/bbmap/align/main'
// local modules
include { DECONTAM                     } from '../modules/local/decontam'
include { CONTIGLIB; CONTIGLIB_CLUSTER } from '../modules/local/contig_library'
include { MAPPING2CONTIGS; CONTIGINDEX; MAPPING2CONTIGS2; ABUNDANCE   } from '../modules/local/abundance'
include { BRACKEN_DB; BRACKEN; BRACKEN_COMBINEBRACKENOUTPUTS } from '../modules/local/bracken'
include { DRAMV; EMAPPER; ABRICATE     } from '../modules/local/annotation'
include { VIRALHOST_IPHOP              } from '../modules/local/viral_host'
include { BACPHLIP; REPLIDEC           } from '../modules/local/replicyc'
include { CHECKV; VIRSORTER2; DVF; VIRCONTIGS_PRE; VIBRANT           } from '../modules/local/viral_detection'
include { GENEPRED as GENEPRED4CTG; NRSEQS as NRPROT; NRSEQS as NRGENE } from '../modules/local/gene_library'
include { TAXONOMY_VCONTACT; TAXONOMY_MMSEQS; TAXONOMY_MERGE           } from '../modules/local/taxonomy'
include { RESULTS_TSE                  } from '../modules/local/base'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

// Info required for completion email and summary
def multiqc_report = []

workflow VIROPROFILER {
    if (params.mode == "setup") {
        SETUP()
    } else {
        ch_multiqc_files = Channel.empty()

        // Check mandatory parameters
        if (params.input) { ch_input = file(params.input) } else { exit 1, 'Input samplesheet not specified!' }
        ch_versions = Channel.empty()

        //
        // SUBWORKFLOW: Read in samplesheet, validate and stage input files
        //
        INPUT_CHECK ( ch_input )

        // if input_type is "clean", set ch_clean_reads to input_reads, otherwise set to FASTP.out.reads
        if (params.reads_type == "clean") {
            ch_clean_reads = INPUT_CHECK.out.reads
        } else {
            // MODULE: Run FastQC
            FASTQC (
                INPUT_CHECK.out.reads
            )
            ch_versions = ch_versions.mix(FASTQC.out.versions.first())

            // MODULE: Run fastp
            FASTP (
                INPUT_CHECK.out.reads, false, false 
            )
            ch_versions = ch_versions.mix(FASTP.out.versions.first())

            // Decontamination
            if (params.use_decontam) {
                ch_contamref = Channel.fromPath("${params.contamref_idx}", checkIfExists: true).first()
                DECONTAM (FASTP.out.reads, ch_contamref)
                ch_clean_reads = DECONTAM.out.reads
                ch_versions = ch_versions.mix(DECONTAM.out.versions.first())
            } else {
                ch_clean_reads = FASTP.out.reads
            }

            ch_multiqc_files = ch_multiqc_files.mix(FASTQC.out.zip.collect{it[1]}.ifEmpty([]))
            ch_multiqc_files = ch_multiqc_files.mix(FASTP.out.json.collect{it[1]}.ifEmpty([]))

            ch_clean_reads = FASTP.out.reads
        }



        // if input_contigs is specified, set ch_cclib to input_contigs, otherwise set to CONTIGLIB.out.cclib_long_ch
        if (params.input_contigs) {
            ch_cclib = Channel.fromPath("${params.input_contigs}", checkIfExists: true).first()
        } else {
            // Run spades
            SPADES (
                ch_clean_reads.map { meta, fastq -> [ meta, fastq, [], [] ] },
                []
            )

            // Use contigs or scaffolds
            if ( params.assemblies == "contigs") {
                assemblies = SPADES.out.contigs
            } else {
                assemblies = SPADES.out.scaffolds
            }

            // Create contig library
            CONTIGLIB(
                assemblies.map { meta, fasta -> [fasta] }.collect()
            )
            ch_cclib = CONTIGLIB.out.cclib_long_ch

            // Extract versions
            ch_versions = ch_versions.mix(SPADES.out.versions.first())
            ch_versions = ch_versions.mix(CONTIGLIB.out.versions)
        }

        // MODULE: CheckV
        CHECKV(ch_cclib)
        clean_cclib_long = CHECKV.out.checkv_qc_ch
        ch_versions = ch_versions.mix(CHECKV.out.versions)

        // MODULE: contig clustering
        CONTIGLIB_CLUSTER (clean_cclib_long)
        ch_nrclib = CONTIGLIB_CLUSTER.out.nrclib_ch
        ch_versions = ch_versions.mix(CONTIGLIB_CLUSTER.out.versions)

        // Gene library
        GENEPRED4CTG (clean_cclib_long, "ccclib_long")
        ch_prot_all = GENEPRED4CTG.out.prot_ch
        ch_gene_all = GENEPRED4CTG.out.gene_fna_ch

        // Non-redundant gene library
        NRPROT (ch_prot_all, "prot", params.prot_cluster_min_similarity, params.prot_cluster_min_coverage)
        ch_nr_prot = NRPROT.out.cluster_rep_ch
        NRGENE (ch_gene_all, "gene", params.gene_cluster_min_similarity, params.gene_cluster_min_coverage)
        ch_nr_gene = NRGENE.out.cluster_rep_ch

        // Gene/Protein annotation
        if (params.use_eggnog) {
            EMAPPER (ch_nr_prot)
            // ch_versions = ch_versions.mix(EMAPPER.out.versions)
        }
        if (params.use_abricate) {
            ABRICATE (ch_nr_gene)
            ch_versions = ch_versions.mix(ABRICATE.out.versions)
        }

        // TODO: Abundance (but in minimap2, replace with bowtie2)
        // MAPPING2CONTIGS (
        //     ch_clean_reads,
        //     ch_nrclib,
        //     CONTIGLIB_CLUSTER.out.nrclib_dict
        // )
        // ch_bams = MAPPING2CONTIGS.out.bams_ch.collect()
        // ch_versions = ch_versions.mix(MAPPING2CONTIGS.out.versions.first())

        CONTIGINDEX (ch_nrclib)
        MAPPING2CONTIGS2 (
            ch_clean_reads,
            CONTIGINDEX.out.bowtie2idx_ch
        )
        ch_bams = MAPPING2CONTIGS2.out.bams_ch.collect()
        ch_versions = ch_versions.mix(MAPPING2CONTIGS2.out.versions.first())
        
        ABUNDANCE (ch_bams)
        // ch_versions = ch_versions.mix(ABUNDANCE.out.versions)


        // Viral detection: DVF + CheckV MQ, HQ, Complete + VirSorter2 + VIBRANT
        VIBRANT(ch_nrclib)
        DVF(ch_nrclib)
        ch_dvfscore = DVF.out.dvfscore_ch
        ch_dvfseq = DVF.out.dvfseq_ch
        ch_dvflist = DVF.out.dvflist_ch

        VIRCONTIGS_PRE(ch_nrclib, ch_dvflist, CHECKV.out.checkv2vContigs_ch, VIBRANT.out.vibrant_ch)
        ch_putative_vList =  VIRCONTIGS_PRE.out.putative_vList_ch
        ch_putative_vContigs =  VIRCONTIGS_PRE.out.putative_vContigs_ch

        // TODO: add back after fix bug in abundance.
        // Binning (optional)
        if ( params.binning ) {
            if ( params.binning == "phamb" ) {
                vMAG_PHAMB(ch_nrclib, ch_dvfscore, ch_bams)
                vContigs_and_vMAGs = vMAG_PHAMB.out
            } else if ( params.binning == "vrhyme" ) {
                vMAG_VRHYME(ch_putative_vContigs, ch_gene_all, ch_prot_all, ch_bams)
                vContigs_and_vMAGs = vMAG_VRHYME.out
            }
        } else {
            vContigs_and_vMAGs = ch_putative_vContigs
        }

        VIRSORTER2(vContigs_and_vMAGs)        // for DRAM-v gene annotation and AMG detection
        ch_vs2contigs = VIRSORTER2.out.vs2_contigs_ch

        // ANNOTATION (AMG)
        if ( params.use_dram ) {
            DRAMV (ch_vs2contigs, VIRSORTER2.out.vs2_affi_ch)
            ch_versions = ch_versions.mix(DRAMV.out.versions)
        }

        // Taxonomy
        TAXONOMY_VCONTACT(vContigs_and_vMAGs)
        TAXONOMY_MMSEQS(vContigs_and_vMAGs)
        TAXONOMY_MERGE(TAXONOMY_VCONTACT.out.taxa_vc_ch, TAXONOMY_MMSEQS.out.taxa_mmseqs_ch)

        // for testing only
        // BRACKEN_DB(TAXONOMY_MMSEQS.out.taxa_mmseqs_ch, vContigs_and_vMAGs)
        // BRACKEN(ch_clean_reads, BRACKEN_DB.out.ch_brackenDB_for_bracken)
        // BRACKEN_COMBINEBRACKENOUTPUTS(BRACKEN.out.ch_reports.collect())


        // Using kraken2 and bracken
        if ( params.use_kraken2 ) {
            BRACKEN(ch_clean_reads, ${params.db}/kraken2)
            BRACKEN_COMBINEBRACKENOUTPUTS(BRACKEN.out.ch_reports.collect())
        }

        // Viral host
        if ( params.use_iphop ) {
            VIRALHOST_IPHOP(vContigs_and_vMAGs)
            ch_versions = ch_versions.mix(VIRALHOST_IPHOP.out.versions)
        }

        ch_versions = ch_versions.mix(VIRSORTER2.out.versions)
        ch_versions = ch_versions.mix(TAXONOMY_VCONTACT.out.versions)
        ch_versions = ch_versions.mix(TAXONOMY_MMSEQS.out.versions)
        ch_versions = ch_versions.mix(TAXONOMY_MERGE.out.versions)
        // ch_versions = ch_versions.mix(BRACKEN.out.versions)

        // Replication cycle
        if ( params.replicyc == "bacphlip" ) {
            BACPHLIP (vContigs_and_vMAGs)
            ch_versions = ch_versions.mix(BACPHLIP.out.versions)
            ch_replicyc = BACPHLIP.out.bacphlip_ch
        } else if ( params.replicyc == "replidec" ) {
            REPLIDEC (vContigs_and_vMAGs)
            ch_versions = ch_versions.mix(REPLIDEC.out.versions)
            ch_replicyc = REPLIDEC.out.replidec_ch
        }

        // TreeSummarizedExperiment
        RESULTS_TSE (ABUNDANCE.out.ab_count_ch, ABUNDANCE.out.ab_tpm_ch, ABUNDANCE.out.ab_covfrac_ch, TAXONOMY_MERGE.out.taxa_mmseqs_ch, CHECKV.out.checkv2vContigs_ch, VIRSORTER2.out.vs2_score_ch, VIBRANT.out.vibrant_quality_ch, DVF.out.dvf2vContigs_ch, ch_replicyc)

        CUSTOM_DUMPSOFTWAREVERSIONS (
            ch_versions.unique().collectFile(name: 'collated_versions.yml')
        )
        
        //
        // MODULE: MultiQC
        //
        workflow_summary    = WorkflowViroprofiler.paramsSummaryMultiqc(workflow, summary_params)
        ch_workflow_summary = Channel.value(workflow_summary)

        ch_multiqc_files = ch_multiqc_files.mix(Channel.from(ch_multiqc_config))
        ch_multiqc_files = ch_multiqc_files.mix(ch_multiqc_custom_config.collect().ifEmpty([]))
        ch_multiqc_files = ch_multiqc_files.mix(ch_workflow_summary.collectFile(name: 'workflow_summary_mqc.yaml'))
        ch_multiqc_files = ch_multiqc_files.mix(CUSTOM_DUMPSOFTWAREVERSIONS.out.mqc_yml.collect())

        MULTIQC (
            ch_multiqc_files.collect()
        )
        multiqc_report = MULTIQC.out.report.toList()
        ch_versions    = ch_versions.mix(MULTIQC.out.versions)
    }
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    COMPLETION EMAIL AND SUMMARY
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow.onComplete {
    if (params.email || params.email_on_fail) {
        NfcoreTemplate.email(workflow, params, summary_params, projectDir, log, multiqc_report)
    }
    NfcoreTemplate.summary(workflow, params, log)
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
