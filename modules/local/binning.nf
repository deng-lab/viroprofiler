process VAMB {
    label "viroprofiler_binning"

    input:
    path(contigs)
    path(bams)

    output:
    path("*")
    path("out_vamb/clusters.tsv")
    path("out_vamb/bins")

    when:
    task.ext.when == null || task.ext.when

    """
    jgi_summarize_bam_contig_depths --outputDepth depth.txt $bams
    cut -f1-3 depth.txt > col1to3.txt
    cut -f1-3 --complement depth.txt > cut.txt
    paste col1to3.txt cut.txt | csvtk filter -t -f "contigLen>=$params.binning_minlen_contig" > depth_clean.txt
    vamb --outdir out_vamb --fasta $contigs -m $params.binning_minlen_contig --jgi depth_clean.txt -o __ --minfasta $params.binning_minlen_contig
    """
}


process PHAMB_RF{
    label "viroprofiler_binning"
    
    input:
    path(CONTIGS)
    path(output_dvf)
    path(hmm_MiComplete)
    path(hmm_VOGDB)
    path(cluster)

    output:
    path("vambbins_RF_predictions.txt"), emit: phamb_out
    path("vamb_bins.1.fna"), emit: phamb_bins
    path("vambbins_aggregated_annotation.txt"), emit: phamb_anno

    when:
    task.ext.when == null || task.ext.when

    """
    run_RF.py -f $CONTIGS -d $output_dvf -p $hmm_MiComplete -g $hmm_VOGDB -c $cluster  -l $params.binning_minlen_contig -m /opt/phamb/workflows/mag_annotation/dbs/RF_model.python39.sav -s $params.binning_minlen_bin -o .
    mv vamb_bins/vamb_bins.1.fna .
    """
}


process VRHYME {
    label 'viroprofiler_binning'

    // TODO nf-core: List required Conda package(s).
    //               Software MUST be pinned to channel (i.e. "bioconda"), version (i.e. "1.10").
    //               For Conda, the build (i.e. "h9402c20_2") must be EXCLUDED to support installation on different operating systems.
    // TODO nf-core: See section in main README for further information regarding finding and adding container addresses to the section below.
    conda (params.enable_conda ? "bioconda::vrhyme=1.1.0" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/YOUR-TOOL-HERE':
        'quay.io/biocontainers/YOUR-TOOL-HERE' }"

    input:
    // TODO nf-core: Where applicable all sample-specific information e.g. "id", "single_end", "read_group"
    //               MUST be provided as an input via a Groovy Map called "meta".
    //               This information may not be required in some instances e.g. indexing reference genome files:
    //               https://github.com/nf-core/modules/blob/master/modules/bwa/index/main.nf
    // TODO nf-core: Where applicable please provide/convert compressed files as input/output
    //               e.g. "*.fastq.gz" and NOT "*.fastq", "*.bam" and NOT "*.sam" etc.
    path(contigs)
    path(genes)
    path(prots)
    path(bams)

    output:
    // TODO nf-core: Named file extensions MUST be emitted for ALL output channels
    path "out_vrhyme", emit: out_vrhyme_ch
    path("vRhyme_all.fasta"), emit: vrhyme_merge_ch
    // TODO nf-core: List additional required output channels/values here
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    
    // TODO nf-core: Where possible, a command MUST be provided to obtain the version number of the software e.g. 1.10
    //               If the software is unable to output a version number on the command-line then it can be manually specified
    //               e.g. https://github.com/nf-core/modules/blob/master/modules/homer/annotatepeaks/main.nf
    //               Each software used MUST provide the software name and version number in the YAML version file (versions.yml)
    // TODO nf-core: It MUST be possible to pass additional parameters to the tool as a command-line string via the "task.ext.args" directive
    // TODO nf-core: If the tool supports multi-threading then you MUST provide the appropriate parameter
    //               using the Nextflow "task" variable e.g. "--threads $task.cpus"
    // TODO nf-core: Please replace the example samtools command below with your module's command
    // TODO nf-core: Please indent the command appropriately (4 spaces!!) to help with readability ;)
    """
    seqkit fx2tab -n $contigs > contigs.list
    extract_gene_by_contig_id.py -i $genes -c contigs.list -o genes_sel.fna
    extract_gene_by_contig_id.py -i $prots -c contigs.list -o prots_sel.faa

    vRhyme \\
        -i $contigs \\
        -g genes_sel.fna \\
        -p prots_sel.faa \\
        -b $bams \\
        -t $task.cpus \\
        -o out_vrhyme \\
        $args

    cut -f1 out_vrhyme/vRhyme_best_bins.*.membership.tsv | sed 1d > bins_ctgid.list
    seqkit grep -v -f bins_ctgid.list $contigs > vRhyme_unbinned.fasta

    # concat bins
    mkdir -p bins
    for bin in \$(ls out_vrhyme/vRhyme_best_bins_fasta/*.fasta); do
        binid=\$(basename \$bin | sed 's/_bin//;s/.fasta//')
        concat_vrhyme_bin.py -i \$bin -o bins/\$binid
    done

    cat bins/*.fasta vRhyme_unbinned.fasta > vRhyme_all.fasta

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        vRhyme: \$(echo \$(vRhyme --version 2>&1) | sed 's/^.*vRhyme //' ))
    END_VERSIONS
    """
}
