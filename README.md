<h1 align="center">LArGe COmparative Omics Network - Markov CLustering</h1>

[![LAGOON-MCL](https://img.shields.io/badge/LAGOON--MCL-v1.1.0-red?labelColor=000000)](https://jroussea.github.io/LAGOON-MCL/)
[![Nextflow](https://img.shields.io/badge/nextflow_DSL2-%E2%89%A5_2.10.0-23aa62?labelColor=000000)](https://www.nextflow.io/)
[![Singularity](https://img.shields.io/badge/run_with-singularity-1d355c?labelColor=000000)](https://sylabs.io/singularity/)

## Introduction

LAGOON-MCL is a FAIR pipeline using [Nextflow](https://www.nextflow.io/docs/latest/index.html) as workflow manager. The main objective of the pipeline is to build putative protein families using sequence similarity networks and graph clustering. To explore the resulting clusters, LAGOON-MCL uses annotations (functional, taxonomic, ...) provided by the user or obtained with the pipeline using [Pfam](http://pfam.xfam.org/). To take sequence exploration a step further, [ESM Metagenomic Atlas](https://esmatlas.com/) clustered at 30% identity can be scanned for information on the protein's three-dimensional structure.

- The first step is to build a Sequence Similarity Network (SSNs), aligning all the sequences against itself with [Diamond BLASTp](https://github.com/bbuchfink/diamond). Network clustering with [Markov CLustering algorithm](https://micans.org/mcl/) (MCL).
- The second [*optional*] step is to obtain information about the sequences (function, taxonomy, etc.). LAGOON-MCL can scan [Pfam](http://pfam.xfam.org/) using [MMseqs2](https://github.com/soedinglab/MMseqs2).
- The third stage of the pipeline calculates a homogeneity score for each cluster based on sequence information (the homogeneity score is calculated for each annotation).
- The last step [*optional*] scans [ESM Metagenomic Atlas(https://esmatlas.com/ (36997632 sequences) with MMseqs2 to obtain information concerning the three-dimensional structure of the proteins present in the network from the similarity between the sequences.

## Start with LAGOON-MCL

1. Install [Nextflow](https://www.nextflow.io/docs/latest/index.html)

2. Install [Singularity](https://docs.sylabs.io/guides/4.2/user-guide/quick_start.html#quick-start)

3. Download the pipeline

```bash
git clone https://github.com/jroussea/lagoon-mcl.git
```

4. Build Singularity images

```bash
bash singularity.sh
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


## Contributions and Support

LAGOON-MCL is actively supported and developed pipeline. Please use the [issue tracker](https://github.com/jroussea/LAGOON-MCL/issues) for malfunctions and the [GitHub discussions](https://github.com/jroussea/LAGOON-MCL/discussions/1) for questions, comments, feature requests, etc.

## Acknowledgments

LArGe cOmparative Omics Networks (LAGOON) Markov CLustering algorithm (MCL) is developed by the [Atelier de BioInformatique](https://bioinfo.mnhn.fr/abi/presentation.FR.html) team of the [Institut de Systématique, Évolution, Biodiversité - UMR 7205](https://isyeb.mnhn.fr/fr) ([National Museum of Natural History](https://www.mnhn.fr/fr), Paris, France).\
LAGOON-MCL is a new version of [LAGOON](https://github.com/Dylkln/LAGOON.git) developed by Dylan Klein.

## Citations

If you use LAGOON-MCL, please cite : 

[1] P. Di Tommaso, M. Chatzou, E. W. Floden, P. P. Barja, E. Palumbo, et C. Notredame, « Nextflow enables reproducible computational workflows », Nat Biotechnol, vol. 35, no 4, p. 316‑319, avr. 2017, doi: [10.1038/nbt.3820](https://doi.org/10.1038/nbt.3820).

[2] G. M. Kurtzer, V. Sochat, et M. W. Bauer, « Singularity: Scientific containers for mobility of compute », PLOS ONE, vol. 12, no 5, p. e0177459, mai 2017, doi: [10.1371/journal.pone.0177459](https://doi.org/10.1371/journal.pone.0177459).

[3] B. Buchfink, K. Reuter, et H.-G. Drost, « Sensitive protein alignments at tree-of-life scale using DIAMOND », Nat Methods, vol. 18, no 4, Art. no 4, avr. 2021, doi: [10.1038/s41592-021-01101-x](https://doi.org/10.1038/s41592-021-01101-x).

[4] A. J. Enright, S. Van Dongen, et C. A. Ouzounis, « An efficient algorithm for large-scale detection of protein families », Nucleic Acids Research, vol. 30, no 7, p. 1575‑1584, avr. 2002, doi: [10.1093/nar/30.7.1575](https://doi.org/10.1093/nar/30.7.1575).

[5] S. van Dongen et C. Abreu-Goodger, « Using MCL to Extract Clusters from Networks », in Bacterial Molecular Networks: Methods and Protocols, J. van Helden, A. Toussaint, et D. Thieffry, Éd., New York, NY: Springer, 2012, p. 281‑295. doi: [10.1007/978-1-61779-361-5_15](https://doi.org/10.1007/978-1-61779-361-5_15).

[6] S. Van Dongen, « Graph Clustering Via a Discrete Uncoupling Process », SIAM J. Matrix Anal. Appl., vol. 30, no 1, p. 121‑141, janv. 2008, doi: [10.1137/040608635](https://doi.org/10.1137/040608635).

[7] W. Shen, B. Sipos, et L. Zhao, « SeqKit2: A Swiss army knife for sequence and alignment processing », iMeta, vol. 3, no 3, p. e191, 2024, doi: [10.1002/imt2.191](https://doi.org/10.1002/imt2.191).

[8] M. Steinegger et J. Söding, « MMseqs2 enables sensitive protein sequence searching for the analysis of massive data sets », Nat Biotechnol, vol. 35, no 11, Art. no 11, nov. 2017, doi: [10.1038/nbt.3988](https://doi.org/10.1038/nbt.3988).

[9] Z. Lin et al., « Evolutionary-scale prediction of atomic-level protein structure with a language model », Science, vol. 379, no 6637, p. 1123‑1130, mars 2023, doi: [10.1126/science.ade2574](https://doi.org/10.1126/science.ade2574).