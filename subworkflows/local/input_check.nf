workflow INPUT_CHECK {
    take:
    ch_input

    main:
    ch_raw_reads = Channel
        .from(ch_input)
        .splitCsv(header: true)
        .map { row ->
                if (row.size() == 3) {
                    def meta = [:]
                    meta.id = row.sample
                    def r1 = row.fastq_1 ? file(row.fastq_1, checkIfExists: true) : false
                    def r2 = row.fastq_2 ? file(row.fastq_2, checkIfExists: true) : false
                    // Check if given combination is valid
                    if (!r1) exit 1, "Invalid input samplesheet: reads_1 can not be empty."
                    if (!r2) exit 1, "Invalid input samplesheet: reads_2 can not be empty."
                    return [ meta, [ file(r1), file(r2) ]]
                } else {
                    exit 1, "Input samplesheet contains row with ${row.size()} column(s). Expects 3."
                }
            }
    
    emit:
    reads = ch_raw_reads
}