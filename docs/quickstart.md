# Quickstart

For a rapid and simple quickstart that enables to understand most of the available features we will use as input a test viromics dataset.

## Required inputs

To run the pipeline, we basically need a samplesheet describing raw reads of samples to be analysed (`--input`) and the path to the directory containing the databases used by viroprofiler (`--db`).

### Prepare the input samplesheet

The input samplesheet is a comma-separated file like the following:

```csv
sample,fastq_1,fastq_2
HT01,${HOME}/viroprofiler/testdata/viroprofiler-test/HT01_R1.fq.gz,${HOME}/viroprofiler/testdata/viroprofiler-test/HT01_R2.fq.gz
HT02,${HOME}/viroprofiler/testdata/viroprofiler-test/HT02_R1.fq.gz,${HOME}/viroprofiler/testdata/viroprofiler-test/HT02_R2.fq.gz
HT04,${HOME}/viroprofiler/testdata/viroprofiler-test/HT04_R1.fq.gz,${HOME}/viroprofiler/testdata/viroprofiler-test/HT04_R2.fq.gz
HT05,${HOME}/viroprofiler/testdata/viroprofiler-test/HT05_R1.fq.gz,${HOME}/viroprofiler/testdata/viroprofiler-test/HT05_R2.fq.gz
HT23,${HOME}/viroprofiler/testdata/viroprofiler-test/HT23_R1.fq.gz,${HOME}/viroprofiler/testdata/viroprofiler-test/HT23_R2.fq.gz
HT24,${HOME}/viroprofiler/testdata/viroprofiler-test/HT24_R1.fq.gz,${HOME}/viroprofiler/testdata/viroprofiler-test/HT24_R2.fq.gz
UC20,${HOME}/viroprofiler/testdata/viroprofiler-test/UC20_R1.fq.gz,${HOME}/viroprofiler/testdata/viroprofiler-test/UC20_R2.fq.gz
UC21,${HOME}/viroprofiler/testdata/viroprofiler-test/UC21_R1.fq.gz,${HOME}/viroprofiler/testdata/viroprofiler-test/UC21_R2.fq.gz
UC24,${HOME}/viroprofiler/testdata/viroprofiler-test/UC24_R1.fq.gz,${HOME}/viroprofiler/testdata/viroprofiler-test/UC24_R2.fq.gz
UC26,${HOME}/viroprofiler/testdata/viroprofiler-test/UC26_R1.fq.gz,${HOME}/viroprofiler/testdata/viroprofiler-test/UC26_R2.fq.gz
UC28,${HOME}/viroprofiler/testdata/viroprofiler-test/UC28_R1.fq.gz,${HOME}/viroprofiler/testdata/viroprofiler-test/UC28_R2.fq.gz
UC29,${HOME}/viroprofiler/testdata/viroprofiler-test/UC29_R1.fq.gz,${HOME}/viroprofiler/testdata/viroprofiler-test/UC29_R2.fq.gz
UC30,${HOME}/viroprofiler/testdata/viroprofiler-test/UC30_R1.fq.gz,${HOME}/viroprofiler/testdata/viroprofiler-test/UC30_R2.fq.gz
UC31,${HOME}/viroprofiler/testdata/viroprofiler-test/UC31_R1.fq.gz,${HOME}/viroprofiler/testdata/viroprofiler-test/UC31_R2.fq.gz
UC32,${HOME}/viroprofiler/testdata/viroprofiler-test/UC32_R1.fq.gz,${HOME}/viroprofiler/testdata/viroprofiler-test/UC32_R2.fq.gz
```

The first line is the header and the following lines are the samples to be analysed. The first column is the sample name, the second and third columns are the paths to the forward and reverse reads, respectively.

### Download test data and ViroProfiler databases

```{bash .annotate hl_lines="3"}
nextflow run deng-lab/viroprofiler \
    --db ${HOME}/viroprofiler \
    -profile singularity \
    --mode "setup"
```

!!! important "About profiles"
    
    Users **must** select one of the available profiles: `docker`, `singularity`, `podman`, `shifter` or `charliecloud`. `conda` may come in near future. Please read more about how to [proper select NF profiles](profiles.md#)

