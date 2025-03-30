#!/usr/bin/env nextflow

// Enable modules
nextflow.enable.dsl = 2

include { MMseqsCreateDB } from '../modules/mmseqs2.nf'
include { MMseqsSearch as PfamSearch   } from '../modules/mmseqs2.nf'
include { MMseqsSearch as AlphafoldSearch   } from '../modules/mmseqs2.nf'
include { PfamProcessing } from '../modules/mmseqs2.nf'

workflow MMSEQS2 {

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
        all_sequences_rename
        name_targetdb
        run
        
    main:

        if (run == "run_pfam") {
            path_targetdb = Channel.fromPath(params.pfam_path, checkIfExists: true)
        }

        if (run == "run_alphafold") {
            path_targetdb = Channel.fromPath(params.alphafold_path, checkIfExists: true)
        }

        MMseqsCreateDB("queryDB", all_sequences_rename)
        path_querydb = MMseqsCreateDB.out.path_db
        name_querydb = MMseqsCreateDB.out.name_db

        if (run == "run_pfam") {
            PfamSearch(path_querydb, name_querydb, path_targetdb, name_targetdb, 'run_pfam')

            PfamProcessing(PfamSearch.out.search_m8, all_sequences_rename)
            label = PfamProcessing.out.file_format
        }

        if (run == "run_alphafold") {
            AlphafoldSearch(path_querydb, name_querydb, path_targetdb, name_targetdb, 'run_alphafold')

            label = AlphafoldSearch.out.search_m8
        }

    emit:
        label
}