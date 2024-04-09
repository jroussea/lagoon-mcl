# LAGOON-MCL

version 1.0.0 \
[Back to table of contents](index.md#table-of-content?target=_blank)

## Requirements

LAGOON-MCL uses [Nextflow](https://www.nextflow.io/?target=_blank) as a workflow manager and [Singularity](https://sylabs.io/singularity/?target=_blank) or [Conda](https://conda.io/projects/conda/en/latest/user-guide/install/index.html?target=_blank) for the use of the different tools.

## Linux

The pipeline was tested on Ubuntu and Debian.

### Installation step (Singularity)

1. Install [Nextflow](https://www.nextflow.io/docs/latest/getstarted.html#installation?target=_blank)
2. Install [Singularity](https://docs.sylabs.io/guides/4.1/user-guide/quick_start.html#quick-installation-steps?target=_blank)
3. Download the pipeline \
Clone the current [GitHub](https://github.com/jroussea/LAGOON-MCL?target=_blank) repository.

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

1. Install [Nextflow](https://www.nextflow.io/docs/latest/getstarted.html#installation?target=_blank)
2. Install [Conda](https://conda.io/projects/conda/en/latest/user-guide/install/index.html?target=_blank) ([Anaconda](https://www.anaconda.com/download?target=_blank) or [Miniconda](https://docs.anaconda.com/free/miniconda/?target=_blank))
3. Download the pipeline \
Clone the current [GitHub](https://github.com/jroussea/LAGOON-MCL?target=_blank) repository.

```bash
git clone https://github.com/jroussea/LAGOON-MCL.git
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