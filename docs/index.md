# Welcome to <u>ViroProfiler</u> pipeline documentation

## About

[ViroProfiler](https://github.com/deng-lab/viroprofiler) is a pipeline designed to provide an easy-to-use framework for performing a comprehensive analyses of viral metagenomics data. It is developed with [Nextflow](https://www.nextflow.io/docs/latest/index.html) and [Docker](https://www.docker.com/). It can detect and characterize viral sequences and communities recovered from metagenomics data.

## Workflow

The pipeline's main steps are:

| Pipeline modules | Used software or databases |
| :------------- | :------------------------- |
| Genome assembly | [metaSPAdes](https://github.com/ablab/spades) |
| Binning | [vRhyme](https://github.com/AnantharamanLab/vRhyme) or [phamb](https://github.com/RasmussenLab/phamb) |
| Viral contig identification | [VirSorter2](https://github.com/jiarong/VirSorter2), [DeepVirFinder](https://github.com/jessieren/DeepVirFinder), [VIBRANT](https://github.com/AnantharamanLab/VIBRANT) and [CheckV](https://bitbucket.org/berkeleylab/checkv/src/master/) |
| Gene function annotation | [DRAM-v](https://github.com/WrightonLabCSU/DRAM), [EggNOG](http://eggnog5.embl.de/) and [abricate](https://github.com/tseemann/abricate) |
| Viral replication cycle prediction |  [BACPHLIP](https://github.com/adamhockenberry/bacphlip) or [Replidec](https://github.com/deng-lab/Replidec) |
| Viral taxonomy annotation | [vConTACT2](https://bitbucket.org/MAVERICLab/vcontact2) and [MMseqs2 taxonomy](https://github.com/soedinglab/MMseqs2) |
| Viral-host prediction | [iPhoP](https://bitbucket.org/srouxjgi/iphop) |
| Results visualization | [MulqiQC](https://multiqc.info/), [R Markdown](https://rmarkdown.rstudio.com/) and [Shiny](https://shiny.rstudio.com/) |

!!! note "Tutorial"

    A [tutorial](tutorial.md#) is available so you can quickly get the gist of the pipeline's capabilities.

