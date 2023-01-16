include { DB_CHECKV; DB_PHAMB; DB_VIRSORTER2; DB_DRAM; DB_VIBRANT; DB_IPHOP; DB_EGGNOG; DB_VOGDB; DB_MICOMPLETEDB; DB_VREFSEQ} from "../../modules/local/setup_db"

workflow SETUP {
    main:
    DB_CHECKV()
    DB_PHAMB()
    DB_VIRSORTER2()
    DB_DRAM()
    DB_VIBRANT()
    DB_IPHOP()
    DB_EGGNOG()
    DB_VOGDB()
    DB_MICOMPLETEDB()
    DB_VREFSEQ()
}
