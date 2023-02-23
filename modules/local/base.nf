process RESULTS_TSE {
    label "viroprofiler_vpfkit"

    input:
    path abundance_count
    path abundance_tpm
    path abundance_covfrac
    path taxa
    path checkv_quality
    path virsorter2_score
    path vibrant_quality
    path dvf_score
    path replicyc_type


    output:
    path "*.rds"

    when:
    task.ext.when == null || task.ext.when

    """
    create_tse.r --fin_abcount abundance_count \\
                 --fin_abtpm abundance_tpm \\
                 --fin_abcov abundance_covfrac \\
                 --fin_taxa taxa \\
                 --fin_checkv checkv_quality \\
                 --fin_virsorter2 virsorter2_score \\
                 --fin_vibrant vibrant_quality \\
                 --fin_dvf dvf_score \\
                 --fin_replicyc replicyc_type
    """
}

