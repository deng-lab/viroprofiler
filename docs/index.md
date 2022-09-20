# Welcome to <u>ViroProfiler</u> pipeline documentation

## About

[ViroProfiler](https://github.com/deng-lab/viroprofiler) is a pipeline designed to provide an easy-to-use framework for performing a comprehensive analyses of viral metagenomics data. It is developed with [Nextflow](https://www.nextflow.io/docs/latest/index.html) and [Docker](https://www.docker.com/). It can detect and characterize viral sequences and communities recovered from metagenomics data.

## Workflow

The pipeline's main steps are:

| Analysis steps | Used software or databases |
| :------------- | :------------------------- |
| Genome assembly (if raw reads are given) | [metaSPAdes](https://github.com/ablab/spades) |
| Binning | [vRhyme](https://github.com/AnantharamanLab/vRhyme) or [phamb](https://github.com/RasmussenLab/phamb) |
| Detect viral sequences | [VirSorter2](https://github.com/jiarong/VirSorter2), [DeepVirFinder](https://github.com/jessieren/DeepVirFinder) and [CheckV](https://bitbucket.org/berkeleylab/checkv/src/master/) |
| Gene function annotation | [DRAMv](https://github.com/WrightonLabCSU/DRAM), [EggNOG](http://eggnog5.embl.de/) and [abricate](https://github.com/tseemann/abricate) |
| Viral replication cycle prediction | [Replidec](https://github.com/deng-lab/Replidec) or [BACPHLIP](https://github.com/adamhockenberry/bacphlip) |
| Viral taxonomy annotation | [vConTACT2](https://bitbucket.org/MAVERICLab/vcontact2) and [MMseqs2 taxonomy](https://github.com/soedinglab/MMseqs2) |
| Viral-host prediction | [iphop](https://bitbucket.org/srouxjgi/iphop) |
| Renderization of automatic reports and shiny app for results interrogation | [R Markdown](https://rmarkdown.rstudio.com/) and [Shiny](https://shiny.rstudio.com/) |

!!! note "Quickstart"

    A [quickstart](quickstart.md#) is available so you can quickly get the gist of the pipeline's capabilities.


## Usage

The pipeline's common usage is very simple as shown below:

```bash
# usual command-line
nextflow run deng-lab/viroprofiler \
    --db "/path/to/db" \
    --input "samplesheet.csv"
```

!!! quote

    Some parameters are required, some are not. Please read the pipeline's manual reference to understand each parameter.
