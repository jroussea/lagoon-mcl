/* ESM Metagenomic Atlas */

include { DownloadESMatlas       } from '../modules/structure_database.nf'
include { DiamondDB              } from '../modules/diamond.nf'
include { DiamondBLASTp          } from '../modules/diamond.nf'
include { FiltrationAlnStructure } from '../modules/diamond.nf'
//include { LabHomScore            } from '../modules/attributes.nf'


workflow SCAN_ESM_ATLAS {
    take:
        scan_esm_atlas
        esm_aln
        proteome

    main:
        if (scan_esm_atlas == true && esm_aln == null) {

            if (params.esm_db == null) {
                DownloadESMatlas()
                esmSeq = DownloadESMatlas.out.esmSequence
            }
            else {
                esmSeq = Channel.fromPath(params.esm_db, checkIfExists: true)
            }

            esmDb = DiamondDB(esmSeq)
            
            //split_fasta_esm = all_sequences.splitFasta(by: 10000, file: true)

            DiamondBLASTp(proteome, esmDb)
            esm_alignment = DiamondBLASTp.out.diamond_alignment

            //esm_alignment = split_alignment_esm.collectFile()
        }
        else if (esm_aln != null) {
            esm_alignment = Channel.fromPath(esm_aln, checkIfExists: true)
            //structure_esm_aln = esm_alignment.collectFile()
        }

        structure_esm_aln = esm_alignment.collectFile(name: "${params.outdir}/esm.tsv")

        FiltrationAlnStructure(structure_esm_aln)	
        structure_esm = FiltrationAlnStructure.out.structure
        
        
        //LabHomScore(structure_esm, "esmAtlas_structure", "structure")

    //emit:
        //esm_label = LabHomScore.out.label_network
}