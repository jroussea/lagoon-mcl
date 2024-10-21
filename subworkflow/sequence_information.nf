include { SequenceLength } from '../modules/sequence.nf'
//include { SequenceAnnotation as Cath } from '../modules/sequence.nf'
//include { SequenceAnnotation as Annot } from '../modules/sequence.nf'
//include { Test } from '../modules/sequence.nf'
include { SequenceHtml } from '../modules/html.nf'
include { SequenceAnnotation } from '../modules/sequence.nf'

workflow SEQUENCE_INFORMATION {
    take:
        quarto
        all_sequences
        diamond_ssn
        label_network

    main:

        SequenceLength(all_sequences, diamond_ssn)
        sequence_length = SequenceLength.out.sequence_length
        sequence_length_network = SequenceLength.out.sequence_length_network

        SequenceAnnotation(label_network, sequence_length_network)
        sequence_network_length = SequenceAnnotation.out.sequence_network_length.collect()
        sequence_initial_length = SequenceAnnotation.out.sequence_initial_length.collect()

        //tuple_cath.view()
        SequenceHtml(quarto, sequence_length, sequence_length_network, sequence_initial_length, sequence_network_length)
        
        //Cath(cath_network)
        //cath_annotation = Cath.out.annotation.collect()

        //Annot(annotation_network)
        //annotation_network = Annot.out.annotation.collect()

        //plouf = annotation.collect()
        //Test(cath_annotation)

}