# Manual

```bash
# Get help in the command line
nextflow run deng-lab/viroprofiler --help
```

!!! tip

    All these parameters are configurable through a configuration file. We encourage users to use the configuration file since it will keep your execution cleaner and more readable. See a [config example](config.md#).

## Input description

### Required

To execute the pipeline users **must** provide raw sequencing reads or assembled contigs as input. When raw reads are used, metaSPAdes assembler is used for assembly. Which means, the minimum required input files are:

* Raw sequencing reads in FASTQ format (compressed or uncompressed), **or**;
* Assembled contigs in FASTA format (compressed or uncompressed).

## Input/output options

| <div style="width:100px">Parameter</div> | Required | Default | Description |
| :--------------------------------------- | :------- | :------ | :---------- |
| `--input`  | :material-check: | NA       | Input samplesheet describing all the samples to be analysed |
| `--output` | :material-check: | output  |  Name of directory to store output values |
| `--viroprofiler_db` | :material-check: | NA | Path containing required ViroProfiler databases |

!!! note "About the samplesheet"
    
    Please read the [samplesheet manual page](samplesheet.md#) to better understand its format.

## Database download options

| <div style="width:120px">Parameter</div> | Required | Default | Description |
| :--------------------------------------- | :------- | :------ | :---------- |
| `--get_dbs`  | :material-close: | false  | Instead of running the analysis workflow, it will try to download required databases and save them in `--output` |

!!! tip ""
    
    The quickstart shows a common usage of these parameters.

## On/Off processes

| <div style="width:180px">Parameter</div> | Required | Default | Description |
| :--------------------------------------- | :------- | :------ | :---------- |
| `--skip_amg_search` | :material-close: | false | Tells whether not to run AMG annotation. It skips both DRAMv annotation |


## Other parameters

| <div style="width:249px">Parameter</div> | Required | Default | Description |
| :--------------------------------------- | :------- | :------ | :---------- |
| `--prot_cluster_min_similarity` | :material-close: | 0.7 | Minimum similarity of protein seqs in the same cluster |
| `--prot_cluster_min_coverage` | :material-close: | 0.9 | Minimum similarity of protein seqs in the same cluster |
| `--binning` | :material-close: | null | Which binning tool to use, `vRhyme`, `phamb` or `false` |
| `--binning_minlen_contig` | :material-close: | 2000 | Congits shorter than this value will not be used for binning |
| `--binning_minlen_bin` | :material-close: | 2000 | Bin size shorter than this value will be removed from down-stream analyses |
| `--dvf_qvalue` | :material-close: | 0.1 | q-value used in `DeepVirFinder` |
| `--virsorter2_groups` | :material-close: | "dsDNAphage" | Viral category detected by `VirSorter2`, could be any combination of `dsDNAphage,NCLDV,RNA,ssDNA,lavidaviridae` |
| `--contig_minlen_vcontact2` | :material-close: | 10000 | Contigs/Bins short than this value will not be used in `vConTACT2` |
| `--pc_inflation` | :material-close: | 1.5 | Protein cluster inflation value used in `vConTACT2` |
| `--vc_inflation` | :material-close: | 1.5 | Viral cluster inflation value used in `vConTACT2` |
| `--taxa_db_source` | :material-close: | "NCBI" | Taxonomy database, could be either `NCBI` or `ICTV` |
| `--replicyc` | :material-close: | "replidec" | Viral replication cycle prediction method, could be either `replidec` or `bacphlip` |


## Max job request options

Set the top limit for requested resources for any single job. If you are running on a smaller system, a pipeline step requesting more resources than are available may cause the Nextflow to stop the run with an error. These options allow you to cap the maximum resources requested by any single job so that the pipeline will run on your system.

!!! note
    
    Note that you can not _increase_ the resources requested by any job using these options. For that you will need your own configuration file. See [the nf-core website](https://nf-co.re/usage/configuration) for details.

| Parameter | Default | Description |
| :-------- | :------ | :---------- |
| `--max_cpus`   | 4     | Maximum number of CPUs that can be requested for any single job   |
| `--max_memory` | 20.GB  | Maximum amount of memory that can be requested for any single job |
| `--max_time`   | 120.h   | Maximum amount of time that can be requested for any single job   |