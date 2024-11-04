#!/usr/bin/env nextflow

// Enable modules
nextflow.enable.dsl = 2

/* ESM Metagenomic Atlas */

include { DownloadEsm  } from '../modules/mmseqs2.nf'
include { MMseqsSearch } from '../modules/mmseqs2.nf'

workflow ESMATLAS {
    
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
        esm_aln
        sequences

    main:
        if (esm_aln == null) {

            if (params.esm_db == null) {
                DownloadESMatlas()
                esmDB = DownloadESMatlas.out.esmSequence

                MMseqsSearch(sequences, esmDB, "esmAtlas30")
                search_m8 = MMseqsSearch.out.search_m8
            }
            else {
                esmDB = Channel.fromPath(params.esm_db, checkIfExists: true)

                MMseqsSearch(sequences, esmDB, params.esm_name)
                search_m8 = MMseqsSearch.out.search_m8
            }
        }
        else if (esm_aln != null) {
            esm_alignment = Channel.fromPath(esm_aln, checkIfExists: true)
        }

        structure_esm_aln = search_m8.collectFile(name: "${params.outdir}/esm.tsv")
}