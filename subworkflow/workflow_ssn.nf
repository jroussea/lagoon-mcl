#!/usr/bin/env nextflow

// Enable modules
nextflow.enable.dsl = 2

include { FiltrationAlnNetwork } from '../modules/data_processing.nf'
include { DiamondDB            } from '../modules/diamond.nf'
include { DiamondBLASTp        } from '../modules/diamond.nf'
include { NetworkMcl           } from '../modules/network.nf'
include { NetworkMclToTsv      } from '../modules/network.nf'
include { NetworkEdge          } from '../modules/network.nf'

workflow SSN {

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
        all_sequences
        split_sequences
        alignment_file
        inflation

    main:
        if (alignment_file == null) {

            DiamondDB(all_sequences)

            DiamondBLASTp(split_sequences, DiamondDB.out.diamond_db, params.sensitivity, params.evalue, params.matrix)
            diamond_alignment = DiamondBLASTp.out.diamond_alignment	
        }
        if (alignment_file != null) {
            diamond_alignment = Channel.fromPath(alignment_file, checkIfExists: true)
        }
        diamond_alignment_filter = diamond_alignment.collectFile(name: "${workDir}/concatenated_files/diamond_alignment.tsv")
        
        FiltrationAlnNetwork(diamond_alignment_filter)

        NetworkMcl(FiltrationAlnNetwork.out.diamond_ssn, inflation)

        NetworkMclToTsv(NetworkMcl.out.tuple_dump)

        NetworkEdge(NetworkMclToTsv.out.network, FiltrationAlnNetwork.out.diamond_ssn)

    emit:
        network = NetworkMclToTsv.out.network
        tuple_edge = NetworkEdge.out.tuple_edge
}