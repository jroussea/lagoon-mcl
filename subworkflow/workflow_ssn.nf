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
            diamond_db = DiamondDB.out.diamond_db

            DiamondBLASTp(split_sequences, diamond_db, params.sensitivity, params.evalue, params.matrix)
            diamond_alignment = DiamondBLASTp.out.diamond_alignment	

            //diamond_alignment = split_diamond_alignment.collectFile(name: "${params.outdir}/diamond_ssn.tsv")
        }
        if (alignment_file != null) {
            diamond_alignment = Channel.fromPath(alignment_file, checkIfExists: true)
        }

        FiltrationAlnNetwork(diamond_alignment)
        diamond_alignment_flt = FiltrationAlnNetwork.out.diamond_ssn

        diamond_ssn = diamond_alignment_flt.collectFile(name: "${params.outdir}/diamond/diamond_ssn.tsv")


        NetworkMcxload(diamond_ssn)        
        tuple_seq_dict_mci = NetworkMcxload.out.tuple_seq_dict_mci

        NetworkMcl(inflation, tuple_seq_dict_mci)
        tuple_mcl = NetworkMcl.out.tuple_mcl

        NetworkMcxdump(tuple_mcl)
        tuple_dump = NetworkMcxdump.out.tuple_dump

        FiltrationCluster(tuple_dump)
        tuple_filtration = FiltrationCluster.out.tuple_filtration

        NetworkMclToTsv(tuple_filtration)

    emit:
        tuple_network = NetworkMclToTsv.out.tuple_network
        network = NetworkMclToTsv.out.network
        diamond_ssn = diamond_ssn.collect()
}