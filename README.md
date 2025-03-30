<h1 align="center">LArGe cOmparative Omics Network - Markov CLustering</h1>

[![LAGOON-MCL](https://img.shields.io/badge/LAGOON--MCL-v1.0.0-red?labelColor=000000)](https://jroussea.github.io/LAGOON-MCL/)
[![Nextflow](https://img.shields.io/badge/nextflow_DSL2-%E2%89%A5_23.10.0-23aa62?labelColor=000000)](https://www.nextflow.io/)
[![Singularity](https://img.shields.io/badge/run_with-singularity-1d355c?labelColor=000000)](https://sylabs.io/singularity/)

## Introduction

LAGOON-MCL is a FAIR pipeline using [Nextflow](https://www.nextflow.io/docs/latest/index.html) as workflow manager. The main objective of the pipeline is to build putative protein families using sequence similarity networks and graph clustering. To explore the resulting clusters, LAGOON-MCL uses annotations (functional, taxonomic, ...) provided by the user or obtained with the pipeline using [Pfam](http://pfam.xfam.org/). To take sequence exploration a step further, [ESM Metagenomic Atlas](https://esmatlas.com/) clustered at 30% identity can be scanned for information on the protein's three-dimensional structure.

- The first step is to build a Sequence Similarity Network (SSNs), aligning all the sequences against itself with [Diamond BLASTp](https://github.com/bbuchfink/diamond). Network clustering with [Markov CLustering algorithm](https://micans.org/mcl/) (MCL).
- The second [*optional*] step is to obtain information about the sequences (function, taxonomy, etc.). LAGOON-MCL can scan [Pfam](http://pfam.xfam.org/) using [MMseqs2](https://github.com/soedinglab/MMseqs2).
- The third stage of the pipeline calculates a homogeneity score for each cluster based on sequence information (the homogeneity score is calculated for each annotation).
