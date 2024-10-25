#!/usr/bin/env nextflow

// Enable modules
nextflow.enable.dsl = 2

/* CATH / Gene3D */

include { DownloadPfam        } from '../modules/download.nf'
include { HMMsearch           } from '../modules/hmmer.nf'
include { PreparationPfam    } from '../modules/pfam.nf'
include { PreparationAnnot   } from '../modules/preparation.nf'

workflow PFAM {

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
        pfam_aln
        proteome

    main:
        if (pfam_aln == null) {

            if (params.pfam_db == null) {
                DownloadPfam()
                hmms = DownloadPfam.out.hmms
            }
            else {
                hmms = Channel.fromPath(params.pfam_db, checkIfExists: true)
            }

            HMMsearch(proteome, hmms, params.Z, params.domE, params.incdomE)
            hmmsearch = HMMsearch.out.hmmsearch_tsv

            all_pfam = hmmsearch.collectFile(name: "${params.outdir}/all_pfam.tsv")

            PreparationPfam(all_pfam)
            label_pfam = PreparationPfam.out.label_pfam

        }
        else if (pfam_aln != null) {
            pfam_annotation = Channel.fromPath(params.pfam_aln, checkIfExists: true)
            PreparationAnnot(pfam_annotation)
            label_pfam = PreparationAnnot.out.label_annotation
        }

    emit:
        label_pfam = label_pfam.collect()
}