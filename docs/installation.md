# LAGOON-MCL

version 1.1.1

## Table of content

* [Presentation](index.md)
* [Intallation](installation.md)
* [Command line options](command.md)
* [Citing LAGOON-MCL](citation.md)
* [Contribution and Support](contact.md)


## Requirements

LAGOON-MCL uses [Nextflow](https://www.nextflow.io/) as a workflow manager and [Singularity](https://sylabs.io/singularity/) or [Conda](https://conda.io/projects/conda/en/latest/user-guide/install/index.html) for the use of the different tools.

## Linux

The pipeline was tested on Ubuntu and Debian.

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
bash build_singularity_containers.sh
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

4. Build containers \
You build conda environment from XXX.yaml files.


```bash
bash build_conda_environment.sh
```

5. Test the pipeline on a minimal dataset with a single command


```bash
nextflow run main.nf -profile test_full,conda
```

## Post-intallation

```bash
chmod +x bin/* 
```