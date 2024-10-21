/* AlphaFolde Protein Structure Database */

include { DownloadAlphafoldDB    } from '../modules/structure_database.nf'
include { DiamondDB              } from '../modules/diamond.nf'
include { DiamondBLASTp          } from '../modules/diamond.nf'
include { FiltrationAlnStructure } from '../modules/diamond.nf'
include { LabHomScore            } from '../modules/attributes.nf'


workflow SCAN_ALPHAFOLD_DB {
    take:
        scan_alphafold_db
        alphafold_aln
        proteome

    main:
        if (scan_alphafold_db == true && alphafold_aln == null) {

			if (alphafold_db == null) {
				DownloadAlphafoldDB()
				afSeq = DownloadAlphafoldDB.out.alfafoldSequence
			}
			else {
				afSeq = Channel.fromPath(params.alphafold_db, checkIfExists: true)
			}
			afDb = DiamondDB(afSeq)
			
			//split_fasta_af = all_sequences.splitFasta(by: 100000)

			DiamondBLASTp(proteome, afDb)
			alphafold_alignment = DiamondBLASTp.out.diamond_alignment

			//alphafold_alignment = af_alignment.collectFile()
		}
		else if (alphafold_aln != null) {
			alphafold_alignment = Channel.fromPath(alphafold_aln, checkIfExists: true)
			//structure_af_aln = alphafold_alignment.collectFile()
		}

		structure_af_aln = alphafold_alignment.collectFile(name: "${params.outdir}/af.tsv")

		FiltrationAlnStructure(structure_af_aln)
		structure_af = FiltrationAlnStructure.out.structure
		
		//LabHomScore(structure_af, "alpholdDb_structure", "structure")

    //emit:
        //af_label = LabHomScore.out.label_network
}