#!/usr/bin/env nextflow

// Enable modules
nextflow.enable.dsl = 2

include { MMSEQS_CREATE_DB       } from '../modules/mmseqs2.nf'
include { MMSEQS_SEARCH          } from '../modules/mmseqs2.nf'
include { ANNOTATIONS_PROCESSING } from '../modules/data_processing.nf'
include { ALPHAFOLD_ALIGNMENTS   } from '../modules/structure_searches.nf'
include { ALPHAFOLD_INFORMATIONS } from '../modules/structure_searches.nf'

workflow STRUCTURE_SEARCHES {

    /*
	* DESCRIPTION
    * -----------
    * Aligns user-supplied sequences against the AlphaFold clusters database
    * Create a sequence annotation file
    */

    take:
        split_fasta_files
        sequences_renamed
        name_alphafolddb
        network

    main:
        path_alphafoldDB = Channel.fromPath(params.alphafold_path, checkIfExists: true)

        MMSEQS_CREATE_DB(split_fasta_files)
        path_querydb = MMSEQS_CREATE_DB.out.path_db

        MMSEQS_SEARCH(path_querydb, path_alphafoldDB, name_alphafolddb, 'alphafoldDB')

        split_alphafold_alignments = MMSEQS_SEARCH.out.search_m8

        alphafold_alignments = split_alphafold_alignments.collectFile(name: "${params.outdir}/lagoon-mcl_output/alignments/mmseqs2_alpahfold_clusters_alignments.m8")

        ALPHAFOLD_ALIGNMENTS(alphafold_alignments)

        ALPHAFOLD_INFORMATIONS(params.uniprot, ALPHAFOLD_ALIGNMENTS.out.alphafold_alignments_filter)
        alphafold_sequences_id = ALPHAFOLD_INFORMATIONS.out.alphafold_sequences_id
        alphafold_clusters_id = ALPHAFOLD_INFORMATIONS.out.alphafold_clusters_id
        alphafold_pfam = ALPHAFOLD_INFORMATIONS.out.alphafold_pfam
        all_alphafold_annotations = alphafold_sequences_id.concat(alphafold_clusters_id).concat(alphafold_pfam)

        ANNOTATIONS_PROCESSING(sequences_renamed, all_alphafold_annotations)

    emit:
        alphafold_annotations = ANNOTATIONS_PROCESSING.out.annotations_files
}