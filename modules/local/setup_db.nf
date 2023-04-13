process DB_VIROPROFILER {
    label "viroprofiler_base"
    label "setup"

    when:
    params.mode == "setup"

    """
    # TODO
    echo "Please download checkv database manually"
    """
}

process DB_CHECKV {
    label "viroprofiler_base"
    label "setup"

    when:
    params.mode == "setup"

    """
    if [ ! -d ${params.db}/checkv ]; then
        checkv download_database $params.db
        mv $params.db/checkv-db-v* $params.db/checkv
    else
        echo "CheckV database already exists"
    fi
    """
}


process DB_PHAMB {
    label "viroprofiler_base"
    label "setup"

    when:
    params.mode == "setup"

    """
    if [ ! -d ${params.db}/phamb ]; then
        mkdir -p $params.db/phamb
        # wget -O $params.db/phamb/RF_model.sav "https://github.com/RasmussenLab/phamb/raw/master/workflows/mag_annotation/dbs/RF_model.sav"
        wget -O $params.db/phamb/RF_model.sav "https://raw.githubusercontent.com/RasmussenLab/phamb/master/phamb/dbs/RF_model.sav"
    else
        echo "PHAMB database already exists"
    fi
    """
}


process DB_VIRSORTER2 {
    label "viroprofiler_virsorter2"
    label "setup"

    when:
    params.mode == "setup"

    """
    if [ ! -d ${params.db}/virsorter2 ]; then
        virsorter setup -d ${params.db}/virsorter2 -j $task.cpus
    else
        echo "VirSorter2 database already exists"
    fi
    """
}


process DB_DRAM {
    label "viroprofiler_geneannot"
    label "setup"

    when:
    params.mode == "setup"

    """
    if [ ! -d ${params.db}/dram ]; then
        # Create DRAM database CONFIG file
        create_dram_config.py -d ${params.db}/dram
        export DRAM_CONFIG_LOCATION=${params.db}/dram/CONFIG
        DRAM-setup.py prepare_databases --output_dir ${params.db}/dram --threads $task.cpus --skip_uniref
    else
        echo "DRAM database already exists"
    fi
    """
}

process DB_VIBRANT {
    label "viroprofiler_vibrant"
    label "setup"

    when:
    params.mode == "setup"

    """
    if [ ! -d ${params.db}/vibrant ]; then
        mkdir -p ${params.db}/vibrant
        export VIBRANT_DATA_PATH="/opt/conda/share/vibrant-1.2.1/db"
        download-db.sh ${params.db}/vibrant
    else
        echo "VIBRANT database already exists"
    fi
    """
}


process DB_VREFSEQ {
    label "viroprofiler_base"
    label "setup"

    when:
    params.mode == "setup"

    """
    # Download NCBI taxonomy
    if [ ! -d ${params.db}/taxonomy/taxdump ]; then
        mkdir dl_taxdump
        cd dl_taxdump
        wget -O taxdump.zip https://ftp.ncbi.nih.gov/pub/taxonomy/taxdump_archive/taxdmp_2022-08-01.zip
        unzip taxdump.zip
        # wget ftp://ftp.ncbi.nih.gov/pub/taxonomy/taxdump.tar.gz
        #tar -zxvf taxdump.tar.gz
        mkdir -p ${params.db}/taxonomy/taxdump
        mv names.dmp nodes.dmp delnodes.dmp merged.dmp ${params.db}/taxonomy/taxdump
        cd ..
        rm -rf dl_taxonkit
    else
        echo "NCBI taxonomy already exists"
    fi

    if [ ! -d ${params.db}/taxonomy/mmseqs_vrefseq ]; then
        wget -O ${params.db}/taxonomy/mmseqs_vrefseq.tar.gz "https://sandbox.zenodo.org/record/1098375/files/mmseqs_vrefseq.tar.gz"
        tar -zxvf ${params.db}/taxonomy/mmseqs_vrefseq.tar.gz -C ${params.db}/taxonomy
        rm ${params.db}/taxonomy/mmseqs_vrefseq.tar.gz
        cd ${params.db}/taxonomy/mmseqs_vrefseq
        mmseqs createdb refseq_viral.faa refseq_viral
        mmseqs createtaxdb refseq_viral tmp --ncbi-tax-dump ../taxdump --tax-mapping-file virus.accession2taxid --threads $task.cpus
        mmseqs createindex refseq_viral tmp --threads $task.cpus
        rm -rf tmp
    else
        echo "vRefSeq database already exists"
    fi
    """
}


process DB_IPHOP {
    label "viroprofiler_host"
    label "setup"

    when:
    params.mode == "setup"

    """
    if [ ! -d ${params.db}/iphop ]; then
        mkdir -p ${params.db}/iphop
        iphop download -d $params.db/iphop -n
        
        # Remove the tar.gz file to save space
        sleep 10
        rm -rf ${params.db}/iphop/iPHoP_db_Sept21.tar.gz
    else
        echo "iPHOP database already exists"
    fi
    """
}


process DB_EGGNOG {
    label "viroprofiler_geneannot"
    label "setup"

    when:
    params.mode == "setup"

    """
    if [ ! -d ${params.db}/eggnog ]; then
        mkdir -p ${params.db}/eggnog
        download_eggnog_data.py --data_dir ${params.db}/eggnog -y
    else
        echo "EggNOG database already exists"
    fi
    """
}


process DB_VOGDB {
    label "viroprofiler_base"
    label "setup"

    when:
    params.mode == "setup"

    """
    if [ ! -d ${params.db}/vogdb ]; then
        mkdir -p ${params.db}/vogdb
        cd ${params.db}/vogdb
        wget -O vog.hmm.tar.gz "http://fileshare.csb.univie.ac.at/vog/latest/vog.hmm.tar.gz"
        tar -zxvf vog.hmm.tar.gz
        rm vog.hmm.tar.gz
        cat VOG*.hmm > AllVOG.hmm
        rm -rf VOG*
    else
        echo "VOGDB database already exists"
    fi
    """
}

process DB_MICOMPLETEDB {
    label "viroprofiler_base"
    label "setup"

    when:
    params.mode == "setup"

    """
    if [ ! -d ${params.db}/micomplete ]; then
        mkdir -p ${params.db}/micomplete
        wget -O ${params.db}/micomplete/Bact105.hmm "https://bitbucket.org/evolegiolab/micomplete/raw/165fea13201922f23fecb0e3c17e8e2cb07dae2d/micomplete/share/Bact105.hmm"
    else
        echo "Micomplete database already exists"
    fi
    """
}


process DB_KRAKEN2 {
    label 'viroprofiler_bracken'
    label "setup"

    when:
    params.mode == "setup"

    """
    # Download Kraken2 taxonomy database
    if [ ! -d ${params.db}/kraken2/taxonomy ]; then
        mkdir -p ${params.db}/kraken2
        cd ${params.db}/kraken2
        kraken2-build --download-taxonomy --db taxonomy --threads $task.cpus
    else
        echo "Kraken2 taxonomy already exists"
    fi

    # Download user-defined Kraken2 database
    if [ ! -d ${params.db}/kraken2/${params.kraken2_db} ]; then
        kraken2-build --download-library ${params.kraken2_db} --db ${params.kraken2_db} --threads $task.cpus
        ln -s ../taxonomy/taxonomy ${params.kraken2_db}
        kraken2-build --build --db ${params.kraken2_db}
        rm ${params.kraken2_db}/taxonomy
        kraken2-build --clean --db ${params.kraken2_db}
    else
        echo "Kraken2 ${params.kraken2_db} database already exists"
    fi

    # If set params.kraken2_clean, remove the taxonomy folder to save ~39 GB storage space
    if [ "${params.kraken2_clean}" == "true" ]; then
        rm -rf ${params.db}/kraken2/taxonomy
    fi
    """
}

