# Installation

## Dependencies

The pipeline require only a UNIX system, [Nextflow](https://www.nextflow.io/docs/latest/index.html#) and either [Docker](https://www.docker.com/) or [Singularity](https://sylabs.io/docs/). Please, for installing these tools refer to their manual.

## Downloading the pipeline

You can easily get a copy of the pipeline with:

```bash
# nextflow pull
nextflow pull deng-lab/viroprofiler
```

!!! warning
    
    The pipeline requires a UNIX system, therefore, Windows users may successfully use this pipeline via the [Linux subsystem for window](https://docs.microsoft.com/pt-br/windows/wsl/install-win10). Nextflow team has made available a [nice tutorial](https://www.nextflow.io/blog.html) about this issue.

## Downloading docker images

The docker images used by the pipeline are:

```bash
docker pull denglab/viroprofiler-base        ;
docker pull denglab/viroprofiler-iphop       ;
docker pull denglab/viroprofiler-dram        ;
docker pull denglab/viroprofiler-vrhyme      ;
docker pull denglab/viroprofiler-annotation  ;
docker pull denglab/viroprofiler-abricate    ;
docker pull denglab/viroprofiler-phamb       ;
docker pull denglab/viroprofiler-replidec    ;
docker pull denglab/viroprofiler-vcontact2   ;
```

!!! info "Using singularity"

    Docker and singularity images are downloaded on the fly. Be sure to properly set `NXF_SINGULARITY_LIBRARYDIR` env variable to a writable directory if using Singularity. This will make that the downloaded images are resuable through different executions. Read more at: https://www.nextflow.io/docs/latest/singularity.html#singularity-docker-hub

    For example, to download the images for docker you may:

    ```bash
    # apply this command to each image
    # just change the "/" and ":" for "-".
    # E.g. Image denglab/viroprofiler-base becomes denglab-viroprofiler-base.img
    singularity pull --dir $NXF_SINGULARITY_LIBRARYDIR denglab-viroprofiler-base.img docker://denglab/viroprofiler-base
    ```

## Testing your installation

After that, you can run the pipeline with a testing dataset by selecting one of the available profiles: 

1. Docker
    * `nextflow run denglab/viroprofiler -profile docker,test`
2. Singularity
    * `nextflow run denglab/viroprofiler -profile singularity,test`

!!! note "About NF profiles"

    Please read more about how to [proper select NF profiles](profiles.md#) to better understand it.