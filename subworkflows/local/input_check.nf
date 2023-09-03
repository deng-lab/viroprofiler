workflow INPUT_CHECK {
    take:
    ch_input

    main:
    ch_input_rows = Channel
        .from(ch_input)
        .splitCsv(header: true)
        .map { row ->
                if (row.size() == 3) {
                    def meta = [:]
                    meta.id = row.sample
                    meta.single_end = params.single_end
                    def r1 = row.fastq_1 ? file(row.fastq_1, checkIfExists: true) : false
                    def r2 = row.fastq_2 ? file(row.fastq_2, checkIfExists: true) : false
                    // Check if given combination is valid
                    if (!r1) exit 1, "Invalid input samplesheet: reads_1 can not be empty."
                    if (!r2 && !params.single_end) exit 1, "Invalid input samplesheet: single-end short reads provided, but command line parameter `--single_end` is false. Note that either only single-end or only paired-end reads must provided."
                    if (r2 && params.single_end) exit 1, "Invalid input samplesheet: paired-end short reads provided, but command line parameter `--single_end` is true. Note that either only single-end or only paired-end reads must provided."
                    if (params.single_end)
                        return [ meta, [ file(r1) ]]
                    else
                        return [ meta, [ file(r1), file(r2) ]]
                } else {
                    exit 1, "Input samplesheet contains row with ${row.size()} column(s). Expects 3."
                }
            }


    // Ensure sample IDs are unique
    ch_input_rows
        .map { id, reads -> id }
        .toList()
        .map { ids -> if( ids.size() != ids.unique().size() ) {exit 1, "ERROR: input samplesheet contains duplicated sample IDs!" } }

    emit:
    reads = ch_input_rows
}
