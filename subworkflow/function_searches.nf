#!/usr/bin/env nextflow

// Enable modules
nextflow.enable.dsl = 2

include { MMSEQS_CREATE_DB } from '../modules/mmseqs2.nf'
include { MMSEQS_SEARCH    } from '../modules/mmseqs2.nf'
include { PFAM_PROCESSING  } from '../modules/data_processing.nf'

workflow FUNCTION_SEARCHES {

    /*
	* DESCRIPTION
    * -----------
    * Aligns user-supplied sequences against the Pfam database
    * Create a sequence annotation file
    */

    take:
        sequences_renamed
        name_pfamDB
        
    main:
        path_pfamDB = Channel.fromPath(params.pfam_path, checkIfExists: true)

        MMSEQS_CREATE_DB(sequences_renamed)
        path_querydb = MMSEQS_CREATE_DB.out.path_db

        MMSEQS_SEARCH(path_querydb, path_pfamDB, name_pfamDB, 'pfamDB')

        PFAM_PROCESSING(MMSEQS_SEARCH.out.search_m8, sequences_renamed)
        pfam_files = PFAM_PROCESSING.out.pfam_files

    emit:
        pfam_files
}