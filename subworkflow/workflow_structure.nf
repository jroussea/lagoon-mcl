#!/usr/bin/env nextflow

// Enable modules
nextflow.enable.dsl = 2

include { AnnotationProcessing  } from '../modules/data_processing.nf'
include { AlphafoldAlignment    } from '../modules/structure.nf'
include { AlphafoldInformations } from '../modules/structure.nf'
include { AlphafoldNetwork      } from '../modules/structure.nf'

workflow STRUCTURE {

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
        network
        alphafold_aln
        all_sequences_rename

    main:
        AlphafoldAlignment(alphafold_aln)
        
        AlphafoldInformations(params.uniprot, AlphafoldAlignment.out.alphafold_aln_filter)
        alphafold_id = AlphafoldInformations.out.alphafold_id
        alphafold_clst = AlphafoldInformations.out.alphafold_clst
        alphafold_pfam = AlphafoldInformations.out.alphafold_pfam
        alphafold_labels = alphafold_id.concat(alphafold_clst).concat(alphafold_pfam)
        
        AnnotationProcessing(all_sequences_rename, alphafold_labels)

        AlphafoldNetwork(network, params.uniprot, AlphafoldAlignment.out.alphafold_aln_filter)

    emit:
        tuple_alphafold = AlphafoldNetwork.out.tuple_alphafold
        labels_alphafold = AnnotationProcessing.out.label_annotation
}