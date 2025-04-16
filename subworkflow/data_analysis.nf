#!/usr/bin/env nextflow

// Enable modules
nextflow.enable.dsl = 2

include { HOMOGENEITY_SCORE    } from '../modules/data_analysis.nf'
include { SEQUENCES_PROCESSING } from '../modules/data_processing.nf'
include { SEQUENCES_FILES      } from '../modules/data_analysis.nf'
include { CLUSTERS_FILES       } from '../modules/data_analysis.nf'
include { HTML_REPORT          } from '../modules/data_analysis.nf'

workflow DATA_ANALYSIS {

    /*
	* DESCRIPTION
    * -----------
    * Workflow analyzes LAGOON-MCL results
    * Generate final TSV files and HTML reports
    */ 

    take:
        sequences_renamed
        network
        all_annotations_and_structures
        tuple_network_edges

    main:
        SEQUENCES_PROCESSING(sequences_renamed, network, all_annotations_and_structures)
        tuple_node_labels = SEQUENCES_PROCESSING.out.tuple_node_labels

        HOMOGENEITY_SCORE(all_annotations_and_structures, network)
        tuple_hom_score = HOMOGENEITY_SCORE.out.tuple_hom_score

        tuple_node_infos = tuple_node_labels.concat(tuple_network_edges).groupTuple(by: 0)

        SEQUENCES_FILES(tuple_node_infos)
        tuple_json_diameter = SEQUENCES_FILES.out.tuple_json_diameter
        tuple_sequences_metrics = SEQUENCES_FILES.out.tuple_sequences_metrics

        tuple_clst_infos = tuple_hom_score.concat(tuple_json_diameter).groupTuple(by: 0)

        CLUSTERS_FILES(tuple_clst_infos)

        tuple_clusters_metrics = CLUSTERS_FILES.out.tuple_clusters_metrics

        tuple_all = tuple_clusters_metrics.concat(tuple_sequences_metrics).concat(tuple_network_edges).groupTuple(by: 0)

        HTML_REPORT(tuple_all)
}
