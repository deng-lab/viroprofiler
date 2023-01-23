process BRACKEN_DB {
    label 'viroprofiler_bracken'

    input:
    path taxa_mmseqs
    path contigs

    output:
    path "brackenDB" , emit: ch_brackenDB_for_bracken

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    csvtk filter -t -f "2!=0" ${taxa_mmseqs} | cut -f1 > contig_with_taxa.list
    seqkit grep -f contig_with_taxa.list ${contigs} > contig_with_taxa.fasta

    csvtk filter -t -f "2!=0" ${taxa_mmseqs} | cut -f1-2 | awk '{print \$1 "\\t" \$1 "|kraken:taxid|" \$2}' > kraken_header.tsv
    seqkit replace -p '^(.+)\$' -r '{kv}' -k kraken_header.tsv contig_with_taxa.fasta > viroprofiler_ref.fasta
    
    # Create kraken2 and bracken database
    wd=\$(pwd)
    mkdir -p brackenDB/taxonomy
    cd brackenDB/taxonomy
    ln -s ${params.db}/bracken/taxonomy/* .
    cd \$wd
    kraken2-build --add-to-library viroprofiler_ref.fasta --db brackenDB
    kraken2-build --build --db brackenDB
    bracken-build -d brackenDB
    kraken2-build --clean --db brackenDB
    """
}

process BRACKEN {
    tag "$meta.id"
    label 'viroprofiler_bracken'

    input:
    tuple val(meta), path(reads)
    path brackenDB

    output:
    tuple val(meta), path('*.classified{.,_}*')     , optional:true, emit: classified_reads_fastq
    tuple val(meta), path('*.unclassified{.,_}*')   , optional:true, emit: unclassified_reads_fastq
    tuple val(meta), path('*classifiedreads.txt')   , optional:true, emit: classified_reads_assignment
    path("*.tsv")                                                  , emit: ch_reports
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
    // WARN: Version information not provided by tool on CLI.
    // Please update version string below when bumping container versions.
    def VERSION = '2.8'
    """
    kraken2 \\
        --db ${brackenDB} \\
        --threads $task.cpus \\
        --report ${prefix}.kraken2.report.txt \\
        --gzip-compressed \\
        $unclassified_option \\
        $classified_option \\
        $readclassification_option \\
        $paired \\
        $args \\
        $reads

    bracken \\
        -d ${brackenDB} \\
        -i '${prefix}.kraken2.report.txt' \\
        -o "${prefix}.tsv"

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        kraken2: \$(echo \$(kraken2 --version 2>&1) | sed 's/^.*Kraken version //; s/ .*\$//')
        bracken: ${VERSION}
    END_VERSIONS
    """
}


process BRACKEN_COMBINEBRACKENOUTPUTS {
    label 'viroprofiler_bracken'

    input:
    path(input)

    output:
    path("abundance_bracken.txt"), emit: ch_abundance_bracken

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
    """
}

