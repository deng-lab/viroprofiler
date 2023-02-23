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

process CONTIGINDEX {
    label "viroprofiler_abundance"

    input:
    path contigs

    output:
    path('bowtie2'), emit: bowtie2idx_ch
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    mkdir -p bowtie2
    bowtie2-build $args --threads $task.cpus $contigs bowtie2/bowtie2idx  

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bowtie2: \$(echo \$(bowtie2 --version 2>&1) | sed 's/^.*bowtie2-align-s version //; s/ .*\$//')
    END_VERSIONS
    """
}


process MAPPING2CONTIGS2 {
    label "viroprofiler_abundance"
    tag "$meta.id"

    input:
    tuple val(meta), path(illumina)
    path bowtie2

    output:
    path "${meta.id}.bam", emit: bams_ch
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when
    
    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def illumina_reads = illumina ? ( meta.single_end ? "-s $illumina" : "-1 ${illumina[0]} -2 ${illumina[1]}" ) : ""
    """
    bowtie2 -x ${bowtie2}/bowtie2idx -1 ${illumina[0]} -2 ${illumina[1]} -S ${meta.id}.sam -p $task.cpus
    samtools view -bS ${meta.id}.sam > ${meta.id}_unsorted.bam
    samtools sort ${meta.id}_unsorted.bam -o ${meta.id}_sorted.bam
    samtools index ${meta.id}_sorted.bam
    coverm filter --bam-files ${meta.id}_sorted.bam --output-bam-files ${meta.id}.bam -t $task.cpus --min-read-percent-identity 0.95
    rm ${meta.id}.sam ${meta.id}_unsorted.bam ${meta.id}_sorted.bam

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bowtie2: \$(echo \$(bowtie2 --version 2>&1) | sed 's/^.*bowtie2-align-s version //; s/ .*\$//')
        samtools: \$(echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//')
        coverm: \$(echo \$(coverm --version 2>&1) | sed 's/^.*coverm //; s/ .*\$//')
    END_VERSIONS
    """
}


process ABUNDANCE {
    label "viroprofiler_base"

    input:
    path bams

    output:
    path "*"
    path "abundance_contigs_count.tsv", emit: ab_count_ch
    path "abundance_contigs_covered_fraction.tsv", emit: ab_covfrac_ch
    path "abundance_contigs_tpm.tsv", emit: ab_tpm_ch
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
    coverm contig --methods tpm --bam-files $bams -t $task.cpus --min-read-percent-identity 0.95 1> abundance_contigs_tpm.tsv 2> log_contig_tpm.txt
    sed -i '1 s/ TPM//g' abundance_contigs_tpm.tsv
    coverm contig --methods rpkm --bam-files $bams -t $task.cpus --min-read-percent-identity 0.95 1> abundance_contigs_rpkm.tsv 2> log_contig_rpkm.txt
    sed -i '1 s/ RPKM//g' abundance_contigs_rpkm.tsv
    
    # compresss count table
    pigz -p $task.cpus abundance_contigs_*.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        coverm: \$(coverm 0.6.1 | sed 's/.* //g')
    END_VERSIONS
    """
}
