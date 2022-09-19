# Quickstart

For a rapid and simple quickstart that enables to understand most of the available features we will use as input a test viromics dataset.

## Required inputs

To run the pipeline, we basically need a samplesheet describing raw reads of samples to to be analysed (`--input`) and the path to the directory containing the databases used by bacannot (`--viroprofiler_db`).

### Prepare the input samplesheet

The input samplesheet is a comma-separated file like the following:

```csv
sample,fastq_1,fastq_2
test1,${HOME}/.nextflow/assets/deng-lab/viroprofiler/test/test1_R1.fq.gz,${HOME}/.nextflow/assets/deng-lab/viroprofiler/test/test1_R2.fq.gz
test2,${HOME}/.nextflow/assets/deng-lab/viroprofiler/test/test2_R1.fq.gz,${HOME}/.nextflow/assets/deng-lab/viroprofiler/test/test2_R2.fq.gz
```

The first line is the header and the following lines are the samples to be analysed. The first column is the sample name, the second and third columns are the paths to the forward and reverse reads, respectively.

### Download ViroProfiler databases

```{bash .annotate hl_lines="5"}
# Download pipeline databases
nextflow run deng-lab/viroprofiler \
    --get_dbs \
    --output viroprofiler_dbs \
    -profile singularity
```

!!! important "About profiles"
    
    Users **must** select one of the available profiles: `docker` or `singularity`. Conda may come in near future. Please read more about how to [proper select NF profiles](profiles.md#)

## Run the pipeline

In this step we will get a major overview of the main pipeline's steps. To run it, we will use the databases (`viroprofiler_dbs`) downloaded in the previous step.

```bash
# Run the pipeline using the test viromics dataset
nextflow run deng-lab/viroprofiler \
    --input samplesheet.csv \
    --output output \
    --viroprofiler_db ./viroprofiler_dbs \
    --max_cpus 10 \
    -profile singularity
```

### Outputs

A glimpse over the main outputs produced by ViroProfiler is given at [outputs](outputs.md#) section.
