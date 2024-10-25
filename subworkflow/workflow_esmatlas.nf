#!/usr/bin/env nextflow

// Enable modules
nextflow.enable.dsl = 2

/* ESM Metagenomic Atlas */

include { DownloadESMatlas       } from '../modules/download.nf'
include { DiamondDB              } from '../modules/diamond.nf'
include { DiamondBLASTp          } from '../modules/diamond.nf'
include { FiltrationAlnStructure } from '../modules/preparation.nf'

workflow ESMATLAS {
    
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
        esm_aln
        proteome

    main:
        if (esm_aln == null) {

            if (params.esm_db == null) {
                DownloadESMatlas()
                esmSeq = DownloadESMatlas.out.esmSequence
            }
            else {
                esmSeq = Channel.fromPath(params.esm_db, checkIfExists: true)
            }

            esmDb = DiamondDB(esmSeq)
            
            DiamondBLASTp(proteome, esmDb, params.sensitivity, params.diamond_evalue, params.matrix)
            esm_alignment = DiamondBLASTp.out.diamond_alignment
        }
        else if (esm_aln != null) {
            esm_alignment = Channel.fromPath(esm_aln, checkIfExists: true)
        }

        structure_esm_aln = esm_alignment.collectFile(name: "${params.outdir}/esm.tsv")

        FiltrationAlnStructure(structure_esm_aln)	
        structure_esm = FiltrationAlnStructure.out.structure
}