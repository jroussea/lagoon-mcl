# LAGOON-MCL

version 1.0.0

## Table of content

* [Presentation](index.md)
* [Intallation](installation.md)
* [Command line options](command.md)
* [Citing LAGOON-MCL](citation.md)
* [Contribution and Support](contact.md)

## Introduction

LArGe cOmparative Omics Networks (LAGOON) Markov CLustering algorithm (MCL) is developed by the [Atelier de BioInformatique](https://bioinfo.mnhn.fr/abi/presentation.EN.html?target=_blank) team of the [Institute of Systematics, Evolution, Biodiversity - UMR 7205](https://isyeb.mnhn.fr/en?target=_blank) ([National Museum of Natural History](https://www.mnhn.fr/en?target=_blank), Paris, France).

LAGOON-MCL is a new version of [LAGOON](https://github.com/Dylkln/LAGOON.git?target=_blank) developed by Dylan Klein.

LAGOON-MCL is a FAIR pipeline that uses [Nextflow](https://www.nextflow.io/?target=_blank) as a workflow manager. The objective of this pipeline is to be able to construct Putative Protein Family (clusters) using [Markov CLustering algorithm](https://github.com/micans/mcl?target=_blank) and pairwise alignments obtained with [Diamond](https://github.com/bbuchfink/diamond?target=_blank).

* [Nextflow version 23.10.0.5889](https://www.nextflow.io/docs/latest/index.html?target=_blank)
* [Singularity version 4.1.0](https://docs.sylabs.io/guides/4.1/user-guide/){:target="_blanck" rel="noopener"}
* [Diamond version 2.1.8](https://github.com/bbuchfink/diamond/wiki?){:target="_blanck"}
* [SeqKit version 2.6.1](https://bioinf.shenwei.me/seqkit/?target=_blank)
* [Markov CLustering algorithm version 22-282](https://github.com/micans/mcl?target=_blank)

## Pipeline

![pipeline](images/pipeline.jpg?target=_blank)