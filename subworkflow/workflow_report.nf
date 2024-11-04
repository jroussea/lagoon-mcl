#!/usr/bin/env nextflow

// Enable modules
nextflow.enable.dsl = 2

include { SequenceLength } from '../modules/preparation.nf'
include { SequenceHtml } from '../modules/report.nf'
include { SequenceAnnotation } from '../modules/preparation.nf'
include { ClusterHtml  } from '../modules/report.nf'
include { HomScoreHtml } from '../modules/report.nf'

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
        quarto
        quarto_2
        all_sequences
        diamond_ssn
        label_network
        network
        tuple_hom_score

    main:

        SequenceLength(all_sequences, diamond_ssn)
        sequence_length = SequenceLength.out.sequence_length
        sequence_length_network = SequenceLength.out.sequence_length_network

        SequenceAnnotation(label_network, sequence_length_network)
        annotation_network = SequenceAnnotation.out.annotation_network.collect()
        length_annotation = SequenceAnnotation.out.length_annotation.collect()

        SequenceHtml(quarto, sequence_length, sequence_length_network, annotation_network, length_annotation)

        all_network = network.collectFile()
        ClusterHtml(quarto_2, all_network)

        //HomScoreHtml(tuple_hom_score)
}