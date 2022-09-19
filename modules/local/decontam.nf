process DECONTAM {
    tag "$meta.id"
    label "viroprofiler_base"

    input:
    tuple val(meta), path(fastq)
    path contam_ref

    output:
    tuple val(meta), path('*.nocontam.fq.gz'), emit: reads
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    input = meta.single_end ? "in=${fastq}" : "in=${fastq[0]} in2=${fastq[1]}"
    output = meta.single_end ? "out=${meta.id}.nocontam.fq.gz" : "out1=${meta.id}_R1.nocontam.fq.gz out2=${meta.id}_R2.nocontam.fq.gz"
    """
    mem=\$(echo ${task.memory} | sed 's/ //g' | sed 's/B//g')
    bbmap.sh \\
        -Xmx\$mem \\
        minid=$params.decontam_min_similarity \\
        $args \\
        path=\$(pwd) \\
        threads=$task.cpus \\
        $input \\
        outu=tmp.fq.gz
    
    reformat.sh in=tmp.fq.gz $output
    rm -rf tmp.fq.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bbmap: \$(bbversion.sh)
    END_VERSIONS
    """
}
