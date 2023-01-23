include { DB_CHECKV; DB_PHAMB; DB_VIRSORTER2; DB_DRAM; DB_VIBRANT; DB_IPHOP; DB_EGGNOG; DB_VOGDB; DB_MICOMPLETEDB; DB_VREFSEQ; DB_KRAKEN2} from "../../modules/local/setup_db"

workflow SETUP {
    main:
    // viral detection
    // DB_VIBRANT()
    // DB_CHECKV()
    // DB_VIRSORTER2()

    // binning
    if (params.use_phamb) {
        DB_PHAMB()
        DB_VOGDB()
        DB_MICOMPLETEDB()
    }

    // gene annotation
    if (params.use_dram) {
        DB_DRAM()
    }
    if (params.use_eggnog) {
        DB_EGGNOG()
    }

    // taxonomy
    // DB_VREFSEQ()
    if (params.use_kraken2) {
        DB_KRAKEN2()
    }

    // contig annotation
    if (params.use_iphop) {
        DB_IPHOP()
    }
}
