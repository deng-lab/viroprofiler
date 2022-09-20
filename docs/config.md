# Configuration File

To download a configuration file template users just use `--get_config` parameter. Using a config file your code is lot more clean and concise.

```bash
# get an example config file
wget -O example_custom.config "https://raw.githubusercontent.com/deng-lab/viroprofiler/main/custom.config"

# modify the config file using your favorite text editor ...
# run with config
nextflow run deng-lab/viroprofiler -c example_custom.config
```

Default configuration
---------------------

```groovy
profiles {
    singularity {
        // Please modify this singularity run options to fit your needs
        // If your data or database is stored in a different disk, you may need to mount it to the container using the `-B /path/to/data:/path/to/data` option
        // singularity.runOptions = "--writable-tmpfs -B /path/to/data:/path/to/data"
    }
    
    // `slurm_denglab` is the default profile used in DengLab at HMGU
    slurm_denglab {
        process.executor       = 'slurm'    // change this to your cluster executor
        process.cpus           = 1
        process.memory         = '8 GB'
        process.queue          = 'normal_q'  // change this to your queue
        process.time           = '120 h'
    }
    // Please specify your own profile here
    // and set the parameters accordingly to your local system
    // e.g.:
    // your_own_profile {
    //     process.executor = 'sge'
    //     process.cpus     = 4
    //     process.memory   = '8 GB'
    // }
}

process {
    withName: FASTP {
        // Non-default parameters for can be set here using `ext.args`
        ext.args = "-f 15 -t 1 -F 15 -T 1 --detect_adapter_for_pe -p -n 1 -l 30 -5 -W 4 -M 20 -r -c -g -x"
        cpus = 4
        memory = "50 GB"
    }
  
    withName: FASTQC {
        ext.args = '--quiet'
    }

    withName: DECONTAM {
        ext.args = 'maxindel=1 bwr=0.16 bw=12 quickmatch fast minhits=2 qtrim=rl trimq=10 pigz=True untrim'
        cpus = 4
        memory = "80 GB"
    }

    withName: SPADES {
        ext.args = "--meta"
        cpus = 4
        memory = "100 GB"
    }

    withName: CONTIGLIB {
        cpus = 4
        memory = "40 GB"
    }

    withName: CHECKV {
        cpus = 1
        memory = "30 GB"
    }

    withName: CONTIGLIB_CLUSTER {
        cpus = 2
        memory = "40 GB"
    }

    withName: MAPPING2CONTIGS {
        cpus = 2
        memory = "60 GB"
    }

    withName: ABUNDANCE {
        cpus = 2
        memory = "40 GB"
    }

    withName: DVF {
        cpus = 8
        memory = "60 GB"
    }

    withName: VAMB {
        cpus = 8 
        memory = "120 GB"
    }

    withName: VRHYME {
        ext.args = "--method longest"
        cpus = 2
        memory = "20 GB"
    }

    withName: NRSEQS {
        cpus = 4
        memory = "80 GB"
    }

    withName: MICOMPLETEDB {
        cpus = 8
        memory = "80 GB"
    }

    withName: VOGDB {
        cpus = 4
        memory = "40 GB"
    }

    withName: EMAPPER {
        cpus = 22
        memory = "300 GB"
    }

    withName: PHAMB_RF {
        cpus = 8
        memory = "80 GB"
    }

    withName: VIRSORTER2 {
        cpus = 4
        memory = "100 GB"
    }

    withName: DRAMV {
        cpus = 1
        memory = "200 GB"
    }

    withName: TAXONOMY_VCONTACT {
        cpus = 4
        memory = "100 GB"
    }

    withName: TAXONOMY_MMSEQS {
        cpus = 4
        memory = "120 GB"
    }

    withName: VIRALHOST_IPHOP {
        cpus = 12
        memory = "300 GB"
    }

    withName: BACPHLIP {
        ext.args = "--multi_fasta"
        cpus = 4
        memory = "80 GB"
    }

    withName: REPLIDEC {
        cpus = 4
        memory = "80 GB"
    }
}
```