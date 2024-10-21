/* CATH / Gene3D */

include { DownloadPfam        } from '../modules/pfam.nf'
include { HMMsearch           } from '../modules/pfam.nf'
//include { PfamAnalysis        } from '../modules/pfam.nf'
//include { LabHomScore         } from '../modules/attributes.nf'
include { PreparationPfam    } from '../modules/data_preparation.nf'
include { PreparationAnnot   } from '../modules/data_preparation.nf'

workflow SCAN_PFAM {
    take:
        scan_pfam
        pfam_aln
        proteome

    main:
        /* CATH / Gene3D */

        //if (params.run_gene3d == true) {
        if (scan_pfam == true && pfam_aln == null) {


            if (params.pfam_db == null) {
                DownloadPfam()
                hmms = DownloadPfam.out.hmms
            }
            else {
                hmms = Channel.fromPath(params.pfam_db, checkIfExists: true)
            }

            //split_fasta_cath = all_sequences.splitFasta(by: 10000, file: true)

            HMMsearch(proteome, hmms)
            hmmsearch = HMMsearch.out.hmmsearch

            all_pfam = hmmsearch.collectFile(name: "${params.outdir}/all_pfam.tsv")

            PreparationPfam(all_pfam)
            label_pfam = PreparationPfam.out.label_pfam

        }
        else if (pfam_aln != null) {
            pfam_annotation = Channel.fromPath(params.pfam_aln, checkIfExists: true)
            PreparationAnnot(pfam_annotation)
            label_pfam = PreparationAnnot.out.label_annotation
        }
        //LabHomScore(classification, "class,architecture,topology,superfamily", "sequence_id")

    emit:
        label_pfam = label_pfam.collect()
}