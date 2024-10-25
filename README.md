# LAGOON-MCL

[![LAGOON-MCL](https://img.shields.io/badge/LAGOON--MCL-v1.1.0-red?labelColor=000000)](https://jroussea.github.io/LAGOON-MCL/)
[![Nextflow](https://img.shields.io/badge/nextflow_DSL2-%E2%89%A5_2.10.0-23aa62?labelColor=000000)](https://www.nextflow.io/)
[![Singularity](https://img.shields.io/badge/run_with-singularity-1d355c?labelColor=000000)](https://sylabs.io/singularity/)

## Introduction

LAGOON-MCL est un pipeline FAIR qui utiklise Nextflow comme workflow manager. L'objectif du pipeline esrt de construire des familles protéiques putative en utilisant les approche reposant sur les graphe (ou réseaux de similarité de séquence). À partir es réseaux, et des annotations (fonctionnelle, structurale, taxonomique, ...) fournit par l'utilsiateur ou calculé par le workflow, il est possible de connaitre la composition, l'orgine, la fonction des séquences qui compose les séquences.

- La première étape du pipeline est de construire un réseau de similarité de séquence, pour cela il aligne toutes les séquences de l'utilisateur contre elle même (alignement par pair all vs all) avec diamond. Un clustering du réseau est ensuite réalisé avec le MArkov CLustering algorithm avec d'obtenir des clusters à partir du réseau.
- La deuxième étape [optionnelle] est d'obtenir des informations concernant la fonction et la structure des protéines. Pour cela il est possible d'utiliser HMMER (hmmsearch) pour aligner les séquences contre les banques de données de profil HMM CATH/Gene3D et Pfam.
- Troisième étape consite à calculer un score d'homogénétié pour chacune des informations fournis par l'utilisateur ou les banque de données scanné par LAGOON-MCL. Ce score d'homogénéité permet de déterminer si les séquences qui compose un même cluster on la même fonction, taxonomie, ...


LArGe cOmparative Omics Networks (LAGOON) Markov CLustering algorithm (MCL) is developed by the [Atelier de BioInformatique](https://bioinfo.mnhn.fr/abi/presentation.FR.html) team of the [Institut de Systématique, Évolution, Biodiversité - UMR 7205](https://isyeb.mnhn.fr/fr) ([National Museum of Natural History](https://www.mnhn.fr/fr), Paris, France).\
LAGOON-MCL is a new version of [LAGOON](https://github.com/Dylkln/LAGOON.git) developed by Dylan Klein.

LAGOON-MCL is a FAIR pipeline that uses [Nextflow](https://www.nextflow.io/) as a workflow manager.\
The objective of this pipeline is to be able to construct Putative Protein Family (clusters) using [Markov CLustering algorithm](https://github.com/micans/mcl) and pairwise alignments obtained with [Diamond](https://github.com/bbuchfink/diamond).

## Documentation

[IN PROGRESS]

## Remerciement

LArGe cOmparative Omics Networks (LAGOON) Markov CLustering algorithm (MCL) is developed by the [Atelier de BioInformatique](https://bioinfo.mnhn.fr/abi/presentation.FR.html) team of the [Institut de Systématique, Évolution, Biodiversité - UMR 7205](https://isyeb.mnhn.fr/fr) ([National Museum of Natural History](https://www.mnhn.fr/fr), Paris, France).\
LAGOON-MCL is a new version of [LAGOON](https://github.com/Dylkln/LAGOON.git) developed by Dylan Klein.

## Contributions and Support

LAGOON-MCL is actively supported and developed pipeline. Please use the [issue tracker](https://github.com/jroussea/LAGOON-MCL/issues) for malfunctions and the [GitHub discussions](https://github.com/jroussea/LAGOON-MCL/discussions/1) for questions, comments, feature requests, etc.

## Citations

1. P. Di Tommaso, M. Chatzou, E. W. Floden, P. P. Barja, E. Palumbo, et C. Notredame, « Nextflow enables reproducible computational workflows », Nat Biotechnol, vol. 35, no 4, p. 316‑319, avr. 2017, doi: [10.1038/nbt.3820](https://doi.org/10.1038/nbt.3820).
2. G. M. Kurtzer, V. Sochat, et M. W. Bauer, « Singularity: Scientific containers for mobility of compute », PLOS ONE, vol. 12, no 5, p. e0177459, mai 2017, doi: [10.1371/journal.pone.0177459](https://doi.org/10.1371/journal.pone.0177459).
3. B. Buchfink, K. Reuter, et H.-G. Drost, « Sensitive protein alignments at tree-of-life scale using DIAMOND », Nat Methods, vol. 18, no 4, Art. no 4, avr. 2021, doi: [10.1038/s41592-021-01101-x](https://doi.org/10.1038/s41592-021-01101-x).
4. S. Van Dongen, « Graph Clustering Via a Discrete Uncoupling Process », SIAM J. Matrix Anal. Appl., vol. 30, no 1, p. 121‑141, janv. 2008, doi: [10.1137/040608635](https://doi.org/10.1137/040608635).
