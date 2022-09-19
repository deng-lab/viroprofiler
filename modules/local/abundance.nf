process MAPPING2CONTIGS {
    label "viroprofiler_base"
    tag "$meta.id"

    input:
    tuple val(meta), path(illumina)
    path contigs
    path contigsdict

    output:
    path "${meta.id}.bam", emit: bams_ch
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when
    
    """
    # Only use paired-end reads for mapping
    minimap2 -t $task.cpus -ax sr $contigs $illumina | \\
        grep -v "^@" | \\
        cat $contigsdict - | \\
        samtools view -F 3584 -b --threads $task.cpus - > ${meta.id}_unsorted.bam
    samtools sort ${meta.id}_unsorted.bam -T tmp_$meta.id --threads $task.cpus -m 3G -o ${meta.id}_tmp.bam
    coverm filter --bam-files ${meta.id}_tmp.bam --output-bam-files ${meta.id}.bam -t $task.cpus --min-read-percent-identity 0.95
    rm ${meta.id}_unsorted.bam ${meta.id}_tmp.bam

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        minimap2: \$(minimap2 --version)
        samtools: \$(echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//')
    END_VERSIONS
    """
}


process ABUNDANCE {
    label "viroprofiler_base"

    input:
    path bams

    output:
    path "*"
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    """
    coverm contig --methods count --bam-files $bams -t $task.cpus --min-read-percent-identity 0.95 1> abundance_contigs_count.tsv 2> log_contig_count.txt
    sed -i '1 s/ Read Count//g' abundance_contigs_count.tsv
    coverm contig --methods trimmed_mean --bam-files $bams -t $task.cpus --min-read-percent-identity 0.95 1> abundance_contigs_trimmed_mean.tsv 2> log_contig_trimmed_mean.txt
    sed -i '1 s/ Trimmed Mean//g' abundance_contigs_trimmed_mean.tsv
    coverm contig --methods covered_fraction --bam-files $bams -t $task.cpus --min-read-percent-identity 0.95 1> abundance_contigs_covered_fraction.tsv 2> log_contig_covered_fraction.txt
    sed -i '1 s/ Covered Fraction//g' abundance_contigs_covered_fraction.tsv
    
    # compresss count table
    pigz -p $task.cpus abundance_contigs_*.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        coverm: \$(coverm 0.6.1 | sed 's/.* //g')
    END_VERSIONS
    """
}