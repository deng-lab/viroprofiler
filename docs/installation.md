# Installation

## Dependencies

The pipeline require only a UNIX system, [Nextflow](https://www.nextflow.io/docs/latest/index.html#) and either [Docker](https://www.docker.com/) or [Singularity](https://sylabs.io/docs/). Please, for installing these tools refer to their manual.

## Downloading the pipeline

You can easily get a copy of the pipeline or update with:

```bash
# download or update to the latest version
nextflow pull deng-lab/viroprofiler

# download a specific version (ex. 1.0)
nextflow pull deng-lab/viroprofiler -r v1.0

# download a specific branch (ex. dev)
nextflow pull deng-lab/viroprofiler -r dev
```

!!! warning
    
    The pipeline requires a UNIX system, therefore, Windows users may successfully use this pipeline via the [Linux subsystem for window](https://docs.microsoft.com/pt-br/windows/wsl/install-win10). Nextflow team has made available a [nice tutorial](https://www.nextflow.io/blog.html) about this issue.

## Downloading docker images

The docker images used by the pipeline are:

```bash
docker pull denglab/viroprofiler-base        ;
docker pull denglab/viroprofiler-binning     ;
docker pull denglab/viroprofiler-abundance   ;
docker pull denglab/viroprofiler-geneannot   ;
docker pull denglab/viroprofiler-vibrant     ;
docker pull denglab/viroprofiler-taxa        ;
docker pull denglab/viroprofiler-host        ;
docker pull denglab/viroprofiler-replicyc    ;
```

!!! info "Using singularity"

    Docker and singularity images are downloaded on the fly. Be sure to properly set `NXF_SINGULARITY_LIBRARYDIR` env variable to a writable directory if using Singularity. This will make that the downloaded images are resuable through different executions. Read more at: https://www.nextflow.io/docs/latest/singularity.html#singularity-docker-hub

    For example, to download the images for singularity you may:

    ```bash
    # apply this command to each image
    # just change the "/" and ":" to "-".
    # ex. Image denglab/viroprofiler-base becomes denglab-viroprofiler-base.img
    singularity pull --dir $NXF_SINGULARITY_LIBRARYDIR denglab-viroprofiler-base.img docker://denglab/viroprofiler-base:latest
    singularity pull --dir $NXF_SINGULARITY_LIBRARYDIR denglab-viroprofiler-binning.img docker://denglab/viroprofiler-binning:latest
    singularity pull --dir $NXF_SINGULARITY_LIBRARYDIR denglab-viroprofiler-abundance.img docker://denglab/viroprofiler-abundance:latest
    singularity pull --dir $NXF_SINGULARITY_LIBRARYDIR denglab-viroprofiler-geneannot.img docker://denglab/viroprofiler-geneannot:latest
    singularity pull --dir $NXF_SINGULARITY_LIBRARYDIR denglab-viroprofiler-vibrant.img docker://denglab/viroprofiler-vibrant:latest
    singularity pull --dir $NXF_SINGULARITY_LIBRARYDIR denglab-viroprofiler-taxa.img docker://denglab/viroprofiler-taxa:latest
    singularity pull --dir $NXF_SINGULARITY_LIBRARYDIR denglab-viroprofiler-host.img docker://denglab/viroprofiler-host:latest
    singularity pull --dir $NXF_SINGULARITY_LIBRARYDIR denglab-viroprofiler-replicyc.img docker://denglab/viroprofiler-replicyc:latest
    ```

## Testing your installation

After that, you can run the pipeline with a testing dataset by selecting one of the available profiles: 

1. Docker
    * `nextflow run denglab/viroprofiler -profile docker,test`
2. Singularity
    * `nextflow run denglab/viroprofiler -profile singularity,test`

!!! note "About NF profiles"

    Please read more about how to [proper select NF profiles](profiles.md#) to better understand it.