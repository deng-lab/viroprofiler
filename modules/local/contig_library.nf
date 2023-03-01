process CONTIGLIB {
    label "viroprofiler_base"

    input:
    path contigs

    output:
    path 'contigs_cclib.fasta.gz'     , emit: cclib_ch
    path 'contigs_cclib_long.fasta.gz', emit: cclib_long_ch
    path 'contigs_cclib_long.dict'    , emit: cclib_long_dict_ch
    path "versions.yml"               , emit: versions

    script: // This script is bundled with the pipeline, in nf-core/viroprofiler/bin/
    """
    # Add sample id to contig name
    for sample_contigs in $contigs;do
        sample_id=\$(echo \${sample_contigs} | sed 's/.contigs.fa.gz//;s/.scaffolds.fa.gz//')
        seqkit replace -p '^' -r "\${sample_id}__" \${sample_contigs} > renamed_contigs_\${sample_id}.fa
    done

    # Merge all contigs into one file
    cat renamed_contigs_* > contigs_cclib.fasta
    seqkit replace -s -p "N+" -r "NNNNNNNNNNN" contigs_cclib.fasta
    gzip contigs_cclib.fasta

    # Select contigs longer than `contig_minlen` for downstream analysis
    seqkit seq -g -j $task.cpus -m $params.contig_minlen contigs_cclib.fasta.gz | pigz -p $task.cpus > contigs_cclib_long.fasta.gz

    # Generate a dict file for VAMB or Phamb binning
    samtools dict contigs_cclib_long.fasta.gz | cut -f1-3 > contigs_cclib_long.dict

    # remove temp files
    rm -rf renamed_contigs_*

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bbmap: \$(bbversion.sh)
        seqkit: \$( seqkit | sed '3!d; s/Version: //' )
        samtools: \$(echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//')
    END_VERSIONS
    """
}


process CONTIGLIB_CLUSTER {
    label "viroprofiler_base"

    input:
    path contigs

    output:
    path "contigs_nrclib.fasta", emit: nrclib_ch
    path "contigs_nrclib.dict", emit: nrclib_dict
    path "contigs_ANIclst.tsv", emit: cANIclst_ch
    path "contigs_ani.tsv"
    path "versions.yml", emit: versions

    script: // This script is bundled with the pipeline, in nf-core/viroprofiler/bin/
    """
    makeblastdb -in $contigs -dbtype nucl -out db
    blastn -query $contigs -db db -outfmt '6 std qlen slen' -max_target_seqs 25000 -perc_identity 90 -num_threads $task.cpus > blast_all2all.tsv
    anicalc.py -i blast_all2all.tsv -o contigs_ani.tsv
    aniclust.py --fna $contigs --ani contigs_ani.tsv --out contigs_ANIclst.map --min_ani $params.contig_cluster_min_similarity --min_tcov $params.contig_cluster_min_coverage --min_qcov 0
    cut -f1 contigs_ANIclst.map | sort -u > contigs_nrclib_ani.list
    seqkit grep -f contigs_nrclib_ani.list $contigs > contigs_nrclib.fasta
    samtools dict contigs_nrclib.fasta | cut -f1-3 > contigs_nrclib.dict
    parse_NRCLib_clusters.py -i contigs_ANIclst.map -o contigs_ANIclst.tsv -m ani

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        blast: \$(blastn -version 2>&1 | sed 's/^.*blastn: //; s/ .*\$//')
        seqkit: \$( seqkit | sed '3!d; s/Version: //' )
        samtools: \$(echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//')
    END_VERSIONS
    """
}
