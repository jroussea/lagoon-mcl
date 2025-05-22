#!/usr/bin/env nextflow

// Enable modules
nextflow.enable.dsl = 2

include { FILTER_ALIGNMENTS } from '../modules/data_processing.nf'
include { DIAMOND_DB        } from '../modules/diamond.nf'
include { DIAMOND_BLASTP    } from '../modules/diamond.nf'
include { GRAPH_CLUSTERING  } from '../modules/graph_clustering.nf'
include { MCL_OUTPUT_TO_TSV } from '../modules/graph_clustering.nf'
include { NETWORK_EDGES     } from '../modules/graph_clustering.nf'

workflow SSN_AND_GRAPH_CLUSTERING {

    /*
	* DESCRIPTION
    * -----------
    * Builds a sequence similarity network (SSN)
    * Applies a graph clustring algorithm to the SSN
    */

    take:
        sequences_renamed
        split_fasta_files
        alignments_file
        inflation

    main:
        if (alignments_file == null) {
            
            DIAMOND_DB(sequences_renamed)

            DIAMOND_BLASTP(split_fasta_files, DIAMOND_DB.out.diamond_db, params.sensitivity, params.evalue, params.matrix)
            diamond_alignments = DIAMOND_BLASTP.out.diamond_alignment	
        }
        if (alignments_file != null) {
            diamond_alignments = Channel.fromPath(alignments_file, checkIfExists: true)
        }
        all_diamond_alignments = diamond_alignments.collectFile(name: "${params.outdir}/lagoon-mcl_output/alignments/diamond_alignments.tsv")

        FILTER_ALIGNMENTS(all_diamond_alignments)

        GRAPH_CLUSTERING(FILTER_ALIGNMENTS.out.mcl_input_file, inflation)

        MCL_OUTPUT_TO_TSV(GRAPH_CLUSTERING.out.tuple_mcl_output)

        NETWORK_EDGES(MCL_OUTPUT_TO_TSV.out.network, FILTER_ALIGNMENTS.out.diamond_ssn)

    emit:
        network = MCL_OUTPUT_TO_TSV.out.network
        tuple_network_edges = NETWORK_EDGES.out.tuple_network_edges
}