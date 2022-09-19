process ABRICATE {
    conda (params.enable_conda ? "bioconda::abricate=1.0.1" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/abricate:1.0.1--ha8f3691_1':
        'quay.io/biocontainers/abricate:1.0.1--ha8f3691_1' }"

    input:
    path gene_fasta

    output:
    path("*.tsv")
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
        abricate: \$(echo \$(abricate -v) | sed 's/^abricate  //' ))
    END_VERSIONS
    """
}
