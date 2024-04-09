# LAGOON-MCL

[![LAGOON-MCL](https://img.shields.io/badge/LAGOON--MCL-v1.0.0-red?labelColor=000000)](https://jroussea.github.io/LAGOON-MCL/)
[![Nextflow](https://img.shields.io/badge/nextflow_DSL2-%E2%89%A5_2.10.0-23aa62?labelColor=000000)](https://www.nextflow.io/)
[![Singularity](https://img.shields.io/badge/run_with-singularity-1d355c?labelColor=000000)](https://sylabs.io/singularity/)
[![Conda](https://img.shields.io/badge/run_with-conda-3eb049?logo=anaconda&labelColor=000000)](https://docs.conda.io/projects/conda/en/stable/)

## Introduction

LArGe cOmparative Omics Networks (LAGOON) Markov CLustering algorithm (MCL) is developed by the [Atelier de BioInformatique](https://bioinfo.mnhn.fr/abi/presentation.FR.html?target=_blank) team of the ![Institut de Systématique, Évolution, Biodiversité - UMR 7205](https://isyeb.mnhn.fr/fr) (![National Museum of Natural History](https://www.mnhn.fr/fr), Paris, France).\
LAGOON-MCL is a new version of ![LAGOON](https://github.com/Dylkln/LAGOON.git) developed by Dylan Klein.

LAGOON-MCL is a FAIR pipeline that uses ![Nextflow](https://www.nextflow.io/) as a workflow manager.\
The objective of this pipeline is to be able to construct Putative Protein Family (clusters) using ![Markov CLustering algorithm](https://github.com/micans/mcl) and pairwise alignments obtained with ![Diamond](https://github.com/bbuchfink/diamond).

## Documentation

The online documentation is located at the ![GitHub Pages](https://jroussea.github.io/LAGOON-MCL/).

## Contributions and Support

LAGOON-MCL is actively supported and developed pipeline. Please use the ![issue tracker](https://github.com/jroussea/LAGOON-MCL/issues) for malfunctions and the ![GitHub discussions](https://github.com/jroussea/LAGOON-MCL/discussions/1) for questions, comments, feature requests, etc.

You can also contact: ![jeremy.rousseau@edu.mnhn.fr](mailto:jeremy.rousseau@edu.mnhn.fr).

## Citations

1. P. Di Tommaso, M. Chatzou, E. W. Floden, P. P. Barja, E. Palumbo, et C. Notredame, « Nextflow enables reproducible computational workflows », Nat Biotechnol, vol. 35, no 4, p. 316‑319, avr. 2017, doi: ![10.1038/nbt.3820](https://doi.org/10.1038/nbt.3820).
2. G. M. Kurtzer, V. Sochat, et M. W. Bauer, « Singularity: Scientific containers for mobility of compute », PLOS ONE, vol. 12, no 5, p. e0177459, mai 2017, doi: ![10.1371/journal.pone.0177459](https://doi.org/10.1371/journal.pone.0177459).
3. B. Buchfink, K. Reuter, et H.-G. Drost, « Sensitive protein alignments at tree-of-life scale using DIAMOND », Nat Methods, vol. 18, no 4, Art. no 4, avr. 2021, doi: ![10.1038/s41592-021-01101-x](https://doi.org/10.1038/s41592-021-01101-x).
4. W. Shen, S. Le, Y. Li, et F. Hu, « SeqKit: A Cross-Platform and Ultrafast Toolkit for FASTA/Q File Manipulation », PLOS ONE, vol. 11, no 10, p. e0163962, oct. 2016, doi: ![10.1371/journal.pone.0163962](https://doi.org/10.1371/journal.pone.0163962).
5. S. Van Dongen, « Graph Clustering Via a Discrete Uncoupling Process », SIAM J. Matrix Anal. Appl., vol. 30, no 1, p. 121‑141, janv. 2008, doi: ![10.1137/040608635](https://doi.org/10.1137/040608635).
