#!/usr/bin/env nextflow

// Enable modules
nextflow.enable.dsl = 2

include { DiamondDB            } from '../modules/diamond.nf'
include { DiamondBLASTp        } from '../modules/diamond.nf'
include { FiltrationAlnNetwork } from '../modules/preparation.nf'
include { NetworkMcxload       } from '../modules/network.nf'
include { NetworkMcl           } from '../modules/network.nf'
include { NetworkMcxdump       } from '../modules/network.nf'
include { NetworkMclToTsv      } from '../modules/network.nf'
include { FiltrationCluster    } from '../modules/network.nf'

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

        FiltrationAlnNetwork(diamond_alignment)

        diamond_ssn = FiltrationAlnNetwork.out.diamond_ssn.collectFile(name: "${params.outdir}/lagoon-mcl_output/diamond/diamond_ssn.tsv")


        NetworkMcxload(diamond_ssn)        

        NetworkMcl(inflation, NetworkMcxload.out.tuple_seq_dict_mci)

        NetworkMcxdump(NetworkMcl.out.tuple_mcl)

        FiltrationCluster(NetworkMcxdump.out.tuple_dump)

        NetworkMclToTsv(FiltrationCluster.out.tuple_filtration)

    emit:
        tuple_network = NetworkMclToTsv.out.tuple_network
        network = NetworkMclToTsv.out.network
        diamond_ssn = diamond_ssn.collect()
}