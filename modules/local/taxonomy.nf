process TAXONOMY_VCONTACT {
    label "viroprofiler_taxa"

    input:
    path contigs

    output:
    path "out_vContact2/genome_by_genome_overview.csv", emit: taxa_vc_ch
    path "out_vContact2/c1.ntw"
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    """
    seqkit seq -m $params.contig_minlen_vcontact2 $contigs > input.fasta
    prodigal-gv -i input.fasta -o all.gff -a all.faa -d all.fna -p meta -f gff
    mkdir -p prodigal
    mv all.faa all.fna prodigal
    seqkit seq -m 1 prodigal/all.faa | sed 's/*//' |  grep -v '^\$' > proteins.faa
    seqkit seq -m 1 prodigal/all.fna | sed 's/*//' |  grep -v '^\$' > genes.fna
    gene_to_genome.py -a proteins.faa -o vcontact_gene2genome.tsv
    vcontact2 --raw-proteins proteins.faa --rel-mode 'Diamond' --proteins-fp vcontact_gene2genome.tsv --db 'ProkaryoticViralRefSeq211-Merged' --pcs-mode MCL --vcs-mode ClusterONE --output-dir out_vContact2 -t $task.cpus --pc-inflation $params.pc_inflation --vc-inflation $params.vc_inflation

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        vConTACT2: \$(grep "This is vConTACT2 " .command.out | sed 's/.* //g;s/=*//g')
    END_VERSIONS
    """
}

process TAXONOMY_MMSEQS {
    label "viroprofiler_base"

    input:
    path contigs

    output:
    path "mmseqsTaxaRst.tsv", emit: taxa_mmseqs_ch
    path "mmseqsTaxaRst_report.*"
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    """
    # Run mmseqs taxonomy
    mmseqs createdb $contigs qry
    mmseqs taxonomy qry ${params.db}/taxonomy/mmseqs_vrefseq/refseq_viral mmseqsTaxaRst tmp --tax-lineage 1 --majority 0.4 --vote-mode 1 --lca-mode 3 --orf-filter 1 --threads $task.cpus

    # report
    mmseqs createtsv qry mmseqsTaxaRst mmseqsTaxaRst.tsv
    mmseqs taxonomyreport ${params.db}/taxonomy/mmseqs_vrefseq/refseq_viral mmseqsTaxaRst mmseqsTaxaRst_report.txt --report-mode 0
    mmseqs taxonomyreport ${params.db}/taxonomy/mmseqs_vrefseq/refseq_viral mmseqsTaxaRst mmseqsTaxaRst_report.html --report-mode 1

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        MMseqs2: \$(grep "MMseqs Version" .command.log | head -n1 | sed 's/.*\t//g')
    END_VERSIONS
    """
}

process TAXONOMY_MERGE {
    label "viroprofiler_taxa"

    input:
    path taxa_vc
    path taxa_mmseqs

    output:
    path "taxonomy.tsv", emit: taxa2abundance_ch
    path "taxa_mmseqs_formatted_all.tsv", emit: taxa_mmseqs_ch
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when
    
    """
    parse_vContact2_vc.py -i $taxa_vc -o taxa_vc2 -a $params.assembler
    parse_mmseqsTaxa.py -i $taxa_mmseqs -o taxa_mmseqs -u "" -s $params.taxa_db_source
    combine_taxa.py -c taxa_vc2.tsv -m taxa_mmseqs.tsv -o taxonomy

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version | sed 's/Python //g')
    END_VERSIONS
    """
}
