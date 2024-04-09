# LAGOON-MCL

version 1.0.0

## Introduction

LArGe cOmparative Omics Networks (LAGOON) Markov CLustering algorithm (MCL) is developed by the [Atelier de BioInformatique](https://bioinfo.mnhn.fr/abi/presentation.EN.html) team of the [Institute of Systematics, Evolution, Biodiversity - UMR 7205](https://isyeb.mnhn.fr/en) ([National Museum of Natural History](https://www.mnhn.fr/en), Paris, France).

LAGOON-MCL is a new version of [LAGOON](https://github.com/Dylkln/LAGOON.git) developed by Dylan Klein.

LAGOON-MCL is a FAIR pipeline that uses [Nextflow](https://www.nextflow.io/) as a workflow manager. The objective of this pipeline is to be able to construct Putative Protein Family (clusters) using [Markov CLustering algorithm](https://github.com/micans/mcl) and pairwise alignments obtained with [Diamond](https://github.com/bbuchfink/diamond).

* Nextflow version 23.10.0.5889
* Singularity version 4.1.0
* Diamond version 2.1.8
* SeqKit version 2.6.1
* Markov CLustering algorithm version 22-282

## Pipeline

![pipeline](https://github.com/jroussea/LAGOON-MCL/blob/main/docs/images/pipeline.jpg?raw=true)