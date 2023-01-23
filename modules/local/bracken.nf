process KRAKEN2 {
    tag "$meta.id"
    label 'viroprofiler_bracken'

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path('*.classified{.,_}*')     , optional:true, emit: classified_reads_fastq
    tuple val(meta), path('*.unclassified{.,_}*')   , optional:true, emit: unclassified_reads_fastq
    tuple val(meta), path('*classifiedreads.txt')   , optional:true, emit: classified_reads_assignment
    tuple val(meta), path('*report.txt')                           , emit: report
    path "versions.yml"                                            , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def paired       = meta.single_end ? "" : "--paired"
    def classified   = meta.single_end ? "${prefix}.classified.fastq"   : "${prefix}.classified#.fastq"
    def unclassified = meta.single_end ? "${prefix}.unclassified.fastq" : "${prefix}.unclassified#.fastq"
    def classified_option = params.save_output_fastqs ? "--classified-out ${classified}" : ""
    def unclassified_option = params.save_output_fastqs ? "--unclassified-out ${unclassified}" : ""
    def readclassification_option = params.save_reads_assignment ? "--output ${prefix}.kraken2.classifiedreads.txt" : ""

    """
    kraken2 \\
        --db ${params.db}/kraken2 \\
        --threads $task.cpus \\
        --report ${prefix}.kraken2.report.txt \\
        --gzip-compressed \\
        $unclassified_option \\
        $classified_option \\
        $readclassification_option \\
        $paired \\
        $args \\
        $reads

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        kraken2: \$(echo \$(kraken2 --version 2>&1) | sed 's/^.*Kraken version //; s/ .*\$//')
    END_VERSIONS
    """
}


process BRACKEN {
    tag "$meta.id"
    label 'viroprofiler_bracken'

    input:
    tuple val(meta), path(kraken_report)

    output:
    path("*.tsv"), emit: reports
    path "versions.yml"          , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ""
    def prefix = task.ext.prefix ?: "${meta.id}"
    // WARN: Version information not provided by tool on CLI.
    // Please update version string below when bumping container versions.
    def VERSION = '2.8'
    """
    bracken \\
        ${args} \\
        -d ${params.db}/kraken2 \\
        -i '${kraken_report}' \\
        -o "${prefix}.tsv"

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bracken: ${VERSION}
    END_VERSIONS
    """
}


process BRACKEN_COMBINEBRACKENOUTPUTS {
    label 'viroprofiler_bracken'

    input:
    path(input)

    output:
    path("abundance_bracken.txt"), emit: abundance_bracken_ch
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    // WARN: Version information not provided by tool on CLI.
    // Please update version string below when bumping container versions.
    def VERSION = '2.8'
    """
    combine_bracken_outputs.py \\
        --files ${input} \\
        -o abundance_bracken.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        combine_bracken_output: ${VERSION}
    END_VERSIONS
    """
}

