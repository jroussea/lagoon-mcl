<h1 align="center">LArGe cOmparative Omics Network - Markov CLustering</h1>

[![LAGOON-MCL](https://img.shields.io/badge/LAGOON--MCL-v1.1.0-red?labelColor=000000)](https://jroussea.github.io/LAGOON-MCL/)
[![Nextflow](https://img.shields.io/badge/nextflow_DSL2-%E2%89%A5_23.10.0-23aa62?labelColor=000000)](https://www.nextflow.io/)
[![Singularity](https://img.shields.io/badge/run_with-singularity-1d355c?labelColor=000000)](https://sylabs.io/singularity/)

## Introduction

LAGOON-MCL is a FAIR pipeline using [Nextflow](https://www.nextflow.io/docs/latest/index.html) as workflow manager. The main objective of the pipeline is to build putative protein families using sequence similarity networks and graph clustering. To explore the resulting clusters, LAGOON-MCL uses annotations (functional, taxonomic, ...) provided by the user or obtained with the pipeline using [Pfam](http://pfam.xfam.org/). To take sequence exploration a step further, [ESM Metagenomic Atlas](https://esmatlas.com/) clustered at 30% identity can be scanned for information on the protein's three-dimensional structure.

- The first step is to build a Sequence Similarity Network (SSNs), aligning all the sequences against itself with [Diamond BLASTp](https://github.com/bbuchfink/diamond). Network clustering with [Markov CLustering algorithm](https://micans.org/mcl/) (MCL).
- The second [*optional*] step is to obtain information about the sequences (function, taxonomy, etc.). LAGOON-MCL can scan [Pfam](http://pfam.xfam.org/) using [MMseqs2](https://github.com/soedinglab/MMseqs2).
- The third stage of the pipeline calculates a homogeneity score for each cluster based on sequence information (the homogeneity score is calculated for each annotation).

![](./assets/pipeline.svg)

## Start with LAGOON-MCL

1. Install [Nextflow](https://www.nextflow.io/docs/latest/index.html)

2. Install [Singularity](https://docs.sylabs.io/guides/4.2/user-guide/quick_start.html#quick-start)

3. Download the pipeline

```bash
git clone https://github.com/jroussea/lagoon-mcl.git
```

4. Build Singularity images

```bash
singularity build --fakeroot containers/diamond/2.1.0/diamond.sif docker://quay.io/biocontainers/diamond:2.1.10--h43eeafb_0

singularity build --fakeroot containers/mcl/22.282/mcl.sif docker://quay.io/biocontainers/mcl:22.282--pl5321h031d066_2

singularity build --fakeroot containers/seqkit/2.9.0/seqkit.sif docker://quay.io/biocontainers/seqkit:2.9.0--h9ee0642_0

singularity build --fakeroot containers/mmseqs2/15.6f452/mmseqs.sif docker://quay.io/biocontainers/mmseqs2:15.6f452--pl5321h6a68c12_3

singularity build --fakeroot containers/lagoon-mcl/1.1.0/lagoon-mcl.sif docker://jroussea/lagoon-mcl:latest
```

5. Test the pipeline

```bash
chmod +x bin/*
nextflow run main.nf -profile test,singularity
```

6. Run your analysis

```bash
nextflow run main.nf -profile custom,singularity [-c <institute_config_file>]
```

## Documentation

For more information about LAGOON-MCL, please read the [documentation](https://jroussea.github.io/lagoon-mcl/).

## Contributions and Support

LAGOON-MCL is actively supported and developed pipeline. Please use the [issue tracker](https://github.com/jroussea/LAGOON-MCL/issues) for malfunctions and the [GitHub discussions](https://github.com/jroussea/LAGOON-MCL/discussions/1) for questions, comments, feature requests, etc.

## Acknowledgments

LArGe cOmparative Omics Networks (LAGOON) Markov CLustering algorithm (MCL) is developed by the [Atelier de BioInformatique](https://bioinfo.mnhn.fr/abi/presentation.FR.html) team of the [Institut de Systématique, Évolution, Biodiversité - UMR 7205](https://isyeb.mnhn.fr/en) ([Muséum National d'Histoire Naturelle](https://www.mnhn.fr/en), Paris, France).\
LAGOON-MCL is a new version of [LAGOON](https://github.com/Dylkln/LAGOON.git) developed by Dylan Klein.

## Citations

If you use LAGOON-MCL, references can be found in [CITATION.md](./CITATION.md)