#!/usr/bin/env nextflow

// Enable modules
nextflow.enable.dsl = 2

include { SeqLength        } from '../modules/preparation.nf'
include { SeqLengthCluster } from '../modules/preparation.nf'
include { HomogeneityScore } from '../modules/statistics.nf'
include { AbundanceMatrix  } from '../modules/statistics.nf'
include { GeneralReport    } from '../modules/report.nf'
include { HomScoreReport   } from '../modules/report.nf'

workflow REPORT {

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
        quarto_seqs_clst
        all_sequences
        network
        tuple_network
        label_network

    main:

        all_network = network.collectFile(name: "${params.outdir}/lagoon-mcl_reports/data/sequences_and_clusters/network.tsv")

        SeqLengthCluster(tuple_network.combine(all_sequences))
        seq_length_network = SeqLengthCluster.out.network_length.collectFile(name: "${params.outdir}/lagoon-mcl_reports/data/sequences_and_clusters/sequence_length_network.tsv")

        SeqLength(all_sequences)

        GeneralReport(quarto_seqs_clst, SeqLength.out.sequence_length, seq_length_network, all_network)

        HomogeneityScore(label_network, tuple_network)
        tuple_hom_score = HomogeneityScore.out.tuple_hom_score.groupTuple(by: 0)

        HomScoreReport(tuple_hom_score)

        AbundanceMatrix(tuple_network.combine(label_network))
}