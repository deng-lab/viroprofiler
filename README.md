# ViroProfiler: a containerized bioinformatics pipeline for viral metagenomic data analysis

[![Nextflow](https://img.shields.io/badge/nextflow%20DSL2-%E2%89%A521.10.3-23aa62.svg)](https://www.nextflow.io/)
[![run with conda](http://img.shields.io/badge/run%20with-conda-3EB049?logo=anaconda)](https://docs.conda.io/en/latest/)
[![run with docker](https://img.shields.io/badge/run%20with-docker-0db7ed?logo=docker)](https://www.docker.com/)
[![run with singularity](https://img.shields.io/badge/run%20with-singularity-1d355c.svg)](https://sylabs.io/docs/)
[![DOI](https://zenodo.org/badge/537899739.svg)](https://zenodo.org/badge/latestdoi/537899739)

```
                                        __
oooooo     oooo oo                    88  88                    .o8o.  oo  ooo
 `888.     .8'  `'                   88 ss 88                   88 `"  `'  `88
  `888.   .8'  ooo  ooood8b  o888o    88__88   ooooo8b  o888o  o88o   ooo   88   .oooo.  ooooo8b
   `888. .8'   `88   88""8P d8' `8b     ||      88""8P d8' `8b  88    `88   88  d8'  `8b  88""8P
    `888.8'     88   88     88   88    _||_     88     88   88  88     88   88  888ooo88  88
     `888'      88   88     88   88  // || \\   88     88   88  88     88   88  88    .o  88
      `8'      o88o o88b     o888o  //      \\ d88b     o888o  o88o   o88o o88o `Y8bd8P' 088b

```

## Introduction

ViroProfiler is a bioinformatics best-practice analysis pipeline for viral metagenomics data analyses.

The pipeline is built using [Nextflow](https://www.nextflow.io), a workflow tool to run tasks across multiple compute infrastructures in a very portable manner. It uses Docker/Singularity containers making installation trivial and results highly reproducible.

![viroprofiler workflow](docs/images/viroprofiler.png)

## Quick Start

1. Install [`Nextflow`](https://www.nextflow.io/docs/latest/getstarted.html#installation) (`>=21.10.3`)

2. Install [`Singularity`](https://www.sylabs.io/guides/3.0/user-guide/) (you can follow [this tutorial](https://singularity-tutorial.github.io/01-installation/)) or [`Docker`](https://docs.docker.com/engine/installation/). Other  [`Podman`](https://podman.io/), [`Shifter`](https://nersc.gitlab.io/development/shifter/how-to-use/) or [`Charliecloud`](https://hpc.github.io/charliecloud/) for full pipeline reproducibility. However, only `Docker` and `Singularity` were tested. _(you can use [`Conda/Mamba`](https://mamba.readthedocs.io/en/latest/installation.html) both to install Nextflow itself and also to manage software within pipelines. Please only use it within pipelines as a last resort; see [docs](https://nf-co.re/usage/configuration#basic-configuration-profiles))_.

3. Download the pipeline and database.

   ```bash
   nextflow run deng-lab/viroprofiler -profile <YOURPROFILE>

   # ex.
   # nextflow run deng-lab/viroprofiler -profile singularity
   ```

   > - If you are using `Singularity`, please set the [`NXF_SINGULARITY_CACHEDIR` or `singularity.cacheDir`](https://www.nextflow.io/docs/latest/singularity.html?#singularity-docker-hub) Nextflow options enables you to store and re-use the images from a central location for future pipeline runs.
   > - If you are using `Docker`, please replace the profile with `docker`: `-profile docker`.
   <!-- > - If you are using `conda`, it is highly recommended to use the [`NXF_CONDA_CACHEDIR` or `conda.cacheDir`](https://www.nextflow.io/docs/latest/conda.html) settings to store the environments in a central location for future pipeline runs. -->

4. Test the pipeline on a minimal dataset,

   ```bash
   nextflow run deng-lab/viroprofiler -profile test,YOURPROFILE
   ```

   Note that some form of configuration will be needed so that Nextflow knows how to fetch the required software. This is usually done in the form of a config profile (`YOURPROFILE` in the example command above). You can chain multiple config profiles in a comma-separated string.

   > - The pipeline comes with config profiles called `docker`, `singularity`, `podman`, `shifter`, `charliecloud` and `conda` which instruct the pipeline to use the named tool for software management. For example, `-profile test,docker`.
   > - Please check [nf-core/configs](https://github.com/nf-core/configs#documentation) to see if a custom config file to run nf-core pipelines already exists for your Institute. If so, you can simply use `-profile <institute>` in your command. This will enable either `docker` or `singularity` and set the appropriate execution settings for your local compute environment.

5. Start running your own analysis!

   ```bash
   nextflow run deng-lab/viroprofiler --input samplesheet.csv -params-file params.yml -profile <docker/singularity/podman/shifter/charliecloud/conda/institute>
   ```

## Updating the pipeline

   ```bash
   nextflow pull deng-lab/viroprofiler
   ```

## Documentation

The ViroProfiler pipeline comes with documentation about the pipeline [usage](docs/usage.md), [parameters](params.yml) and [output](docs/output.md).

## Credits

ViroProfiler was originally written by Jinlong Ru.

We thank the following people for their extensive assistance in the development of this pipeline:

- ...

## Contributions and Support

If you would like to contribute to this pipeline, please see the [contributing guidelines](.github/CONTRIBUTING.md).

For further information or help, please [open an issue](https://github.com/deng-lab/viroprofiler/issues).

## Citations

If you use  ViroProfiler for your analysis, please cite the publication as follows:

> ViroProfiler: a containerized bioinformatics pipeline for viral metagenomic data analysis
>
> *Jinlong Ru, Mohammadali Khan Mirzaei, Jinling Xue, Xue Peng, Li Deng*
>
> [journal]

An extensive list of references for the tools and data used by the pipeline can be found in the [`CITATIONS.md`](CITATIONS.md) file.

This pipeline uses code and infrastructure developed and maintained by the [nf-core](https://nf-co.re) initative, and reused here under the [MIT license](https://github.com/nf-core/tools/blob/master/LICENSE). You can cite the `nf-core` publication as follows:

> The nf-core framework for community-curated bioinformatics pipelines.
>
> *Philip Ewels, Alexander Peltzer, Sven Fillinger, Harshil Patel, Johannes Alneberg, Andreas Wilm, Maxime Ulysse Garcia, Paolo Di Tommaso & Sven Nahnsen.*
>
> *Nat Biotechnol. 2020 Feb 13. doi: [10.1038/s41587-020-0439-x](https://dx.doi.org/10.1038/s41587-020-0439-x).*
