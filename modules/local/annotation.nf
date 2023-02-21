process DRAMV {
    label "viroprofiler_geneannot"

    input:
    path contigs
    path AFFI

    output:
    path "dramv-annotate"
    path "dramv-distill"
    path "dramv-annotate/genes.faa", emit: dramv_proteins_ch
    path "dramv-annotate/scaffolds.fna", emit: dramv_contigs_ch
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    """
    # Due to limitation of container, DRAM database path is hardset to /opt/conda/db2
    # So we need to create a soft link for the database path
    ln -s ${params.db} /opt/conda/db2
    export DRAM_CONFIG_LOCATION=${params.db}/dram/CONFIG
    
    DRAM-v.py annotate -i $contigs -v $AFFI -o dramv-annotate --threads $task.cpus --min_contig_size $params.contig_minlen
    DRAM-v.py distill -i dramv-annotate/annotations.tsv -o dramv-distill

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        DRAM: 1.3
    END_VERSIONS
    """
}


process MICOMPLETEDB{
    label "viroprofiler_base"
    
    input:
    path(prot)

    output:
    path("hmmMiComplete.tbl"), emit: hmm_miComplete

    when:
    task.ext.when == null || task.ext.when

    """
    hmmsearch --cpu $task.cpus -E 1.0e-05 -o out_miComplete --tblout hmmMiComplete.tbl ${params.db}/micomplete/Bact105.hmm $prot
    """
}


process VOGDB{
    label "viroprofiler_base"
    
    input:
    path(prot)

    output:
    path("hmmVOG.tbl"), emit: hmm_VOGDB

    when:
    task.ext.when == null || task.ext.when

    """
    hmmsearch --cpu $task.cpus -E 1.0e-05 -o out_vogdb --tblout hmmVOG.tbl ${params.db}/vogdb/AllVOG.hmm $prot
    """
}

process EMAPPER {
    label "viroprofiler_geneannot"

    input:
    path(prot_faa)

    output:
    path("anno_eggnog.tsv"), emit: anno_eggnog_ch

    when:
    task.ext.when == null || task.ext.when

    """
    emapper.py -i $prot_faa -o eggnog --cpu $task.cpus --no_file_comments -m diamond --data_dir ${params.db}/eggnog
    parse_eggnog.py -i eggnog.emapper.annotations -o anno_eggnog.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        emapper: \$(echo \$(emapper.py -v) | grep version | cut -d' ' -f1 | sed 's/emapper-/v/g')
    END_VERSIONS
    """
}


// process ABRICATE {
//     label "viroprofiler_geneannot"

//     input:
//     path(genes)

//     output:
//     path("*.tsv")

//     when:
//     task.ext.when == null || task.ext.when

//     """
//     for abrdb in argannot card ecoh ncbi plasmidfinder resfinder vfdb;do
//         abricate --db \$abrdb $genes > ARG_\${abrdb}.tsv
//     done

//     head -n1 ARG_argannot.tsv | cut -f2- > anno_abricate.tsv
//     cat ARG_* | grep -v "^#FILE" | cut -f2- | sort -k1,2 >> anno_abricate.tsv
//     """
// }


process ABRICATE {
    conda (params.enable_conda ? "bioconda::abricate=1.0.1" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/abricate:1.0.1--ha8f3691_1':
        'quay.io/biocontainers/abricate:1.0.1--ha8f3691_1' }"

    input:
    path gene_fasta

    output:
    path "*.tsv"
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    
    """
    for abrdb in argannot card ecoh ncbi plasmidfinder resfinder vfdb;do
        abricate --db \$abrdb $args $gene_fasta > ARG_\${abrdb}.tsv
    done

    head -n1 ARG_argannot.tsv | cut -f2- > anno_abricate.tsv
    cat ARG_* | grep -v "^#FILE" | cut -f2- | sort -k1,2 >> anno_abricate.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        abricate: \$(echo \$(abricate -v) | sed 's/^abricate  //' )
    END_VERSIONS
    """
}