#!/usr/bin/env nextflow

// Enable modules
nextflow.enable.dsl = 2

include { SeqLength        } from '../modules/preparation.nf'
include { SeqLengthCluster } from '../modules/preparation.nf'
include { GeneralReport    } from '../modules/report.nf'
include { HomogeneityScore } from '../modules/statistics.nf'


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
        all_sequences
        network
        tuple_network
        label_network

    main:

        HomogeneityScore(label_network, tuple_network)
        tuple_hom_score = HomogeneityScore.out.tuple_hom_score
        tuple_hom_score = tuple_hom_score.groupTuple(by: 0)


        quarto_seqs_clst = Channel.fromPath("${projectDir}/bin/report_seqs_clst.qmd")

        tuple_network_fasta = tuple_network.combine(all_sequences)
        SeqLengthCluster(tuple_network_fasta)
        seq_length_network = SeqLengthCluster.out.network_length.collectFile(name: "${params.outdir}/lagoon-mcl_reports/data/sequences_and_clusters/sequence_length_network.tsv")

        SeqLength(all_sequences)
        seq_length = SeqLength.out.sequence_length

        all_network = network.collectFile(name: "${params.outdir}/lagoon-mcl_reports/data/sequences_and_clusters/network.tsv")

        GeneralReport(quarto_seqs_clst, seq_length, seq_length_network, all_network)
}