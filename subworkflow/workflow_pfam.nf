#!/usr/bin/env nextflow

// Enable modules
nextflow.enable.dsl = 2

/* Pfam */

include { DownloadPfam     } from '../modules/mmseqs2.nf'
include { MMseqsSearch     } from '../modules/mmseqs2.nf'
include { PreparationPfam  } from '../modules/preparation.nf'

workflow PFAM {

    /*
	* DESCRIPTION
    * -----------
    *
    * INPUT
    * -----
    * 	- 
    * OUPUT
    * -----
    *	- 
    */

    take:
        sequences

    main:

        if (params.pfam_db == null) {
            DownloadPfam()

            MMseqsSearch(sequences, DownloadPfam.out.pfamDB, "pfam")
        }
        else {
            pfamDB = Channel.fromPath(params.pfam_db, checkIfExists: true)

            MMseqsSearch(sequences, pfamDB, params.pfam_name)
        }

        PreparationPfam(MMseqsSearch.out.search_m8)

    emit:
        label_pfam = PreparationPfam.out.select_pfam.collectFile(name: "${params.outdir}/lagoon-mcl_output/annotation/pfam.tsv").collect()
}