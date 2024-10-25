#!/usr/bin/env nextflow

// Enable modules
nextflow.enable.dsl = 2

/* AlphaFolde Protein Structure Database */

include { DownloadAlphafoldDB    } from '../modules/download.nf'
include { DiamondDB              } from '../modules/diamond.nf'
include { DiamondBLASTp          } from '../modules/diamond.nf'
include { FiltrationAlnStructure } from '../modules/preparation.nf'

workflow ALPHAFOLDDB {

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
        alphafold_aln
        proteome

    main:
        if (alphafold_aln == null) {

			if (alphafold_db == null) {
				DownloadAlphafoldDB()
				afSeq = DownloadAlphafoldDB.out.alfafoldSequence
			}
			else {
				afSeq = Channel.fromPath(params.alphafold_db, checkIfExists: true)
			}
			afDb = DiamondDB(afSeq)
			
			DiamondBLASTp(proteome, afDb, params.sensitivity, params.diamond_evalue, params.matrix)
			alphafold_alignment = DiamondBLASTp.out.diamond_alignment
		}
		else if (alphafold_aln != null) {
			alphafold_alignment = Channel.fromPath(alphafold_aln, checkIfExists: true)
		}

		structure_af_aln = alphafold_alignment.collectFile(name: "${params.outdir}/af.tsv")

		FiltrationAlnStructure(structure_af_aln)
		structure_af = FiltrationAlnStructure.out.structure
}