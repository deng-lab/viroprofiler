# Tutorial

This tutorial will walk you through the installation and usage of ViroProfiler. ViroProfiler is containerized with [Docker](https://www.docker.com/), and can be used with multiple container engines, including [Docker](https://www.docker.com), [Singularity](https://sylabs.io/singularity/), [`Podman`](https://podman.io/), [`Shifter`](https://nersc.gitlab.io/development/shifter/how-to-use/) and [`Charliecloud`](https://hpc.github.io/charliecloud/) (see [docs](https://www.nextflow.io/docs/latest/container.html)). In this tutorial, we will use [Singularity](https://sylabs.io/singularity/) as an example.

## Install dependencies

1. Install [Miniconda3](https://docs.conda.io/en/latest/miniconda.html) (`>=21.10.3`).

2. Install Nextflow and Singularity using conda:

```bash
# You may need to restart your terminal before running the following commands
conda install -c conda-forge -c bioconda nextflow singularity
```

## Install ViroProfiler

ViroProfiler is built on Nextflow, which means it is very easy to install with a single command:

```bash
nextflow run deng-lab/viroprofiler -profile singularity
```

By default, database will be downloaded to the `$HOME/viroprofiler` directory. You can change database path using the `--db` parameter. For example, if you want to download the database to `/db/path` directory, you can run the following command,

```bash
nextflow run deng-lab/viroprofiler -profile singularity --db "/db/path"
```

> - It is recommended to set the [`NXF_SINGULARITY_CACHEDIR` or `singularity.cacheDir`](https://www.nextflow.io/docs/latest/singularity.html?#singularity-docker-hub) Nextflow options when using the Singularity profile, so that singularity images can be stored and re-used from a central location for future pipeline runs.
> - If you are using `Docker`, please replace the `-profile singularity` with `-profile docker`.
<!-- > - If you are using `conda`, it is highly recommended to use the [`NXF_CONDA_CACHEDIR` or `conda.cacheDir`](https://www.nextflow.io/docs/latest/conda.html) settings to store the environments in a central location for future pipeline runs. -->

When you run the above command, Nextflow automatically pulls the pipeline code from GitHub and stores it as a cached version. When running the pipeline after this, it will always use the cached version if available. To make sure that you're running the latest version of the pipeline, make sure that you regularly update the cached version of the pipeline:

```bash
nextflow pull deng-lab/viroprofiler
```

## Run the ViroProfiler pipeline

### Prepare input files

#### Samplesheet input

To execute the pipeline users **must** provide raw sequencing reads as input. You will need to create a samplesheet with information about the samples you would like to analyse before running the pipeline. Use this parameter to specify its location. It has to be a comma-separated file with 3 columns, and a header row as shown in the examples below.

```console
--input "[path to samplesheet file]"
```

#### Multiple runs of the same sample

The `sample` identifiers have to be the same when you have re-sequenced the same sample more than once e.g. to increase sequencing depth. The pipeline will concatenate the raw reads before performing any downstream analysis. Below is an example for the same sample sequenced across 3 lanes:

```console
sample,fastq_1,fastq_2
CONTROL_REP1,AEG588A1_S1_L002_R1_001.fastq.gz,AEG588A1_S1_L002_R2_001.fastq.gz
CONTROL_REP1,AEG588A1_S1_L003_R1_001.fastq.gz,AEG588A1_S1_L003_R2_001.fastq.gz
CONTROL_REP1,AEG588A1_S1_L004_R1_001.fastq.gz,AEG588A1_S1_L004_R2_001.fastq.gz
```

#### Full samplesheet

The pipeline will auto-detect whether a sample is single- or paired-end using the information provided in the samplesheet. The samplesheet can have as many columns as you desire, however, there is a strict requirement for the first 3 columns to match those defined in the table below.

A final samplesheet file consisting of both single- and paired-end data may look something like the one below. This is for 6 samples, where `TREATMENT_REP3` has been sequenced twice.

```console
sample,fastq_1,fastq_2
CONTROL_REP1,AEG588A1_S1_L002_R1_001.fastq.gz,AEG588A1_S1_L002_R2_001.fastq.gz
CONTROL_REP2,AEG588A2_S2_L002_R1_001.fastq.gz,AEG588A2_S2_L002_R2_001.fastq.gz
CONTROL_REP3,AEG588A3_S3_L002_R1_001.fastq.gz,AEG588A3_S3_L002_R2_001.fastq.gz
TREATMENT_REP1,AEG588A4_S4_L003_R1_001.fastq.gz,
TREATMENT_REP2,AEG588A5_S5_L003_R1_001.fastq.gz,
TREATMENT_REP3,AEG588A6_S6_L003_R1_001.fastq.gz,
TREATMENT_REP3,AEG588A6_S6_L004_R1_001.fastq.gz,
```

| Column    | Description |
| --------- | ----------- |
| `sample`  | Custom sample name. This entry will be identical for multiple sequencing libraries/runs from the same sample. Spaces in sample names are automatically converted to underscores (`_`). |
| `fastq_1` | Full path to FastQ file for Illumina short reads 1. File has to be gzipped and have the extension ".fastq.gz" or ".fq.gz". |
| `fastq_2` | Full path to FastQ file for Illumina short reads 2. File has to be gzipped and have the extension ".fastq.gz" or ".fq.gz". |

An [example samplesheet](../assets/samplesheet.csv) has been provided with the pipeline.

### Run the pipeline

The typical command for running the pipeline is as follows:

```console
nextflow run deng-lab/viroprofiler \
    --input samplesheet.csv \
    -profile singularity
```

This will launch the pipeline with the `singularity` configuration profile. See [Selecting NF profiles](profiles.md#) for more information about profiles.

You may create a config file to customize the parameters of the pipeline and use `-c` to load the config. Please check [custom.config](https://github.com/deng-lab/viroprofiler/blob/main/custom.config) for an example. You may also specify the parameters in a file and use `-params-file` to load the parameters. Please check [params.yml](https://github.com/deng-lab/viroprofiler/blob/main/params.yml) for an example. Then the command for running the pipeline is as follows:

```console
nextflow run deng-lab/viroprofiler \
    --input samplesheet.csv \
    --output output \
    --db ${HOME}/viroprofiler \
    -c custom.config \
    -params-file params.yml \
    -profile singularity
```

Note that the pipeline will create the following files in your working directory:

```console
work                # Directory containing the nextflow working files
output              # Finished results in specified location (defined with --outdir)
.nextflow_log       # Log file from Nextflow
# Other nextflow hidden files, eg. history of pipeline runs and old logs.
```

### Reproducible data analysis

For reproducibility, we recommend using a specific version of ViroProfiler. You can always run a specific version of ViroProfiler by specifying the version number. This ensures that a specific version of the pipeline code and software are used when you run your pipeline. If you keep using the same tag, you'll be running the same version of the pipeline, even if there have been changes to the code since. First, go to the [deng-lab/viroprofiler releases page](https://github.com/deng-lab/viroprofiler/releases) and find the latest version number (eg. `v0.1`). Then specify this when running the pipeline with `-r` (one hyphen) - eg. `-r v0.1`. This version number will be logged in reports when you run the pipeline, so that you'll know what you used when you look back in the future. For example, to run version `v0.1` of the pipeline:

```bash
nextflow run deng-lab/viroprofiler -r v0.1 -profile singularity
```

### Description of pipeline options and parameters

To get a list of pipeline options and parameters, run the pipeline with the `--help` flag:

```bash
nextflow run deng-lab/viroprofiler --help

# get full list of options and parameters
nextflow run deng-lab/viroprofiler --help --show_hidden_params
```

!!! tip

    All these parameters are configurable through a configuration file. We encourage users to use the configuration file since it will keep your execution cleaner and more readable. See a [config example](config.md).

#### Core Nextflow options

> **NB:** These options are part of Nextflow and use a _single_ hyphen (pipeline parameters use a double-hyphen).

##### `-profile`

Use this parameter to choose a configuration profile. Profiles can give configuration presets for different compute environments. See [profile](profiles.md) for more information.

##### `-resume`

Specify this when restarting a pipeline. Nextflow will use cached results from any pipeline steps where the inputs are the same, continuing from where it got to previously. For input to be considered the same, not only the names must be identical but the files' contents as well. For more info about this parameter, see [this blog post](https://www.nextflow.io/blog/2019/demystifying-nextflow-resume.html).

You can also supply a run name to resume a specific run: `-resume [run-name]`. Use the `nextflow log` command to show previous run names.

##### `-c`

Specify the path to a specific config file (this is a core Nextflow command). See the [nf-core website documentation](https://nf-co.re/usage/configuration) for more information.


#### Custom pipeline parameters

##### Input/output options

| <div style="width:100px">Parameter</div> | Required | Default | Description |
| :--------------------------------------- | :------- | :------ | :---------- |
| `--input`  | :material-check: | NA       | Input samplesheet describing all the samples to be analysed |
| `--output` | :material-check: | output  |  Name of directory to store output values |
| `--db` | :material-check: | ${HOME}/viroprofiler | Path containing required ViroProfiler databases |

##### On/Off processes

| <div style="width:180px">Parameter</div> | Required | Default | Description |
| :--------------------------------------- | :------- | :------ | :---------- |
| `--skip_amg_search` | :material-close: | false | Tells whether not to run AMG annotation. It skips both DRAMv annotation |


##### Other parameters

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


##### Max job request options

Set the top limit for requested resources for any single job. If you are running on a smaller system, a pipeline step requesting more resources than are available may cause the Nextflow to stop the run with an error. These options allow you to cap the maximum resources requested by any single job so that the pipeline will run on your system.

!!! note
    
    Note that you can not _increase_ the resources requested by any job using these options. For that you will need your own configuration file. See [the nf-core website](https://nf-co.re/usage/configuration) for details.

| Parameter | Default | Description |
| :-------- | :------ | :---------- |
| `--max_cpus`   | 4     | Maximum number of CPUs that can be requested for any single job   |
| `--max_memory` | 20.GB  | Maximum amount of memory that can be requested for any single job |
| `--max_time`   | 120.h   | Maximum amount of time that can be requested for any single job   |

### Outputs

A glimpse over the main outputs produced by ViroProfiler is given at [outputs](outputs.md#) section.
