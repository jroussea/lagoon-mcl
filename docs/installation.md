# LAGOON-MCL

version 1.0.1

## Table of content

* [Presentation](index.md)
* [Intallation](installation.md)
* [Command line options](command.md)
* [Citing LAGOON-MCL](citation.md)
* [Contribution and Support](contact.md)


## Requirements

LAGOON-MCL uses [Nextflow](https://www.nextflow.io/) as a workflow manager and [Singularity](https://sylabs.io/singularity/) or [Conda](https://conda.io/projects/conda/en/latest/user-guide/install/index.html) for the use of the different tools.

## Linux

The pipeline was tested on Ubuntu 20.04 and Ubuntu 22.04.

### Installation step (Singularity)

1. Install [Nextflow](https://www.nextflow.io/docs/latest/getstarted.html#installation)
2. Install [Singularity](https://docs.sylabs.io/guides/4.1/user-guide/quick_start.html#quick-installation-steps)
3. Download the pipeline \
Clone the current [GitHub](https://github.com/jroussea/LAGOON-MCL) repository.

```bash
git clone https://github.com/jroussea/LAGOON-MCL.git &&
cd LAGOON-MCL
```

4. Build containers \
You build container images from XXX.sif files.

```bash
bash singularity_containers.sh
```

5. Test the pipeline on a minimal dataset with a single command 

```bash
nextflow run main.nf -profile test_full,singularity
```

### Installation step (Conda)

1. Install [Nextflow](https://www.nextflow.io/docs/latest/getstarted.html#installation)
2. Install [Conda](https://conda.io/projects/conda/en/latest/user-guide/install/index.html) ([Anaconda](https://www.anaconda.com/download) or [Miniconda](https://docs.anaconda.com/free/miniconda/))
3. Download the pipeline \
Clone the current [GitHub](https://github.com/jroussea/LAGOON-MCL) repository.

```bash
git clone https://github.com/jroussea/LAGOON-MCL.git &&
cd LAGOON-MCL
```

4. Test the pipeline on a minimal dataset with a single command

```bash
nextflow run main.nf -profile test_full,conda
```

## Post-intallation

If you get a `permission denied` when you run the workflow, you'll need to assign execution rights to the various scripts in the `bin/` folder.

```bash
chmod +x bin/* 
```

## Shiny application

In order to interactively explore the results obtained with LAGOON-MCL, I am currently developing a R Shiny application. It is available on [GitHub](https://github.com/jroussea/LAGOON-MCL-Shiny-app).