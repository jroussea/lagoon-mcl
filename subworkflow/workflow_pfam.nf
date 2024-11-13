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
            pfamDB = DownloadPfam.out.pfamDB

            MMseqsSearch(sequences, pfamDB, "pfam")
            search_m8 = MMseqsSearch.out.search_m8
        }
        else {
            pfamDB = Channel.fromPath(params.pfam_db, checkIfExists: true)

            MMseqsSearch(sequences, pfamDB, params.pfam_name)
            search_m8 = MMseqsSearch.out.search_m8
        }

        PreparationPfam(search_m8)
        select_pfam = PreparationPfam.out.select_pfam

        pfam_annotation = select_pfam.collectFile(name: "${params.outdir}/lagoon-mcl_output/annotation/pfam.tsv")

    emit:
        label_pfam = pfam_annotation.collect()
}