#!/usr/bin/env nextflow

// Enable modules
nextflow.enable.dsl = 2

include { HomogeneityScore         } from '../modules/analysis.nf'
include { NodeAnnotationProcessing } from '../modules/data_processing'
include { NodesFiles               } from '../modules/analysis.nf'
include { ClustersFiles            } from '../modules/analysis.nf'
include { HtmlReports              } from '../modules/analysis.nf'

workflow ANALYSIS {

    /*
	* DESCRIPTION
    * -----------
    *
    * -----
    * 	- 
    * OUPUT
    * -----
    *	- 
    */ 

    take:
        all_sequences
        network
        all_labels
        tuple_alphafold
        tuple_edge

    main:
        NodeAnnotationProcessing(all_sequences, network, all_labels)
        tuple_node_labels = NodeAnnotationProcessing.out.tuple_node_labels

        HomogeneityScore(all_labels, network)
        tuple_hom_score = HomogeneityScore.out.tuple_hom_score

        tuple_node_infos = tuple_node_labels.concat(tuple_edge).concat(tuple_alphafold).groupTuple(by: 0)

        NodesFiles(tuple_node_infos)
        tuple_json_diameter = NodesFiles.out.tuple_json_diameter
        tuple_nodes_metrics = NodesFiles.out.tuple_nodes_metrics

        tuple_clst_infos = tuple_hom_score.concat(tuple_json_diameter).groupTuple(by: 0)

        ClustersFiles(tuple_clst_infos)

        tuple_clusters_metrics = ClustersFiles.out.tuple_clusters_metrics

        tuple_all = tuple_clusters_metrics.concat(tuple_nodes_metrics).concat(tuple_edge).groupTuple(by: 0)

        HtmlReports(tuple_all)
}
