/* CATH / Gene3D */

include { DownloadGene3D      } from '../modules/gene3d.nf'
include { HMMsearch           } from '../modules/gene3d.nf'
include { CathResolveHits     } from '../modules/gene3d.nf'
include { AssignSuperfamilies } from '../modules/gene3d.nf'
include { SelectSuperfamilies } from '../modules/gene3d.nf'
include { CathAnalysis        } from '../modules/gene3d.nf'
include { LabHomScore         } from '../modules/attributes.nf'


workflow SCAN_GENE3D {
    take:
        scan_gene3d
        gene3d_aln
        proteome

    main:
        /* CATH / Gene3D */

        //if (params.run_gene3d == true) {
        if (scan_gene3d == true && gene3d_aln == null) {


            if (params.hmm_profile == null && params.domain_list == null && params.discontinuous == null) {
                DownloadGene3D()
                hmms = DownloadGene3D.out.hmms
                cath_domain_list = DownloadGene3D.out.cath_domain_list
                discontinuous_regs = DownloadGene3D.out.discontinuous_regs
            }
            else {
                hmms = Channel.fromPath(params.hmm_profile, checkIfExists: true)
                cath_domain_list = Channel.fromPath(params.domain_list, checkIfExists: true)
                discontinuous_regs = Channel.fromPath(params.discontinuous, checkIfExists: true)
            }

            //split_fasta_cath = all_sequences.splitFasta(by: 10000, file: true)

            HMMsearch(proteome, hmms)
            hmmsearch = HMMsearch.out.hmmsearch

            CathResolveHits(hmmsearch)
            cath_resolve_hits = CathResolveHits.out.cath_resolve_hits

            AssignSuperfamilies(cath_resolve_hits, cath_domain_list, discontinuous_regs)
            superfamilies = AssignSuperfamilies.out.superfamilies
        }
        else if (gene3d_aln != null) {
            superfamilies = Channel.fromPath(gene3d_aln, checkIfExists: true)
        }

        SelectSuperfamilies(superfamilies)
        select_cath = SelectSuperfamilies.out.select_cath

        cath_annotation = select_cath.collectFile(name: "${params.outdir}/cath/cath_superfamilies.csv")

        CathAnalysis(cath_annotation)
        classification = CathAnalysis.out.classification

        LabHomScore(classification, "class,architecture,topology,superfamily", "sequence_id")

    emit:
        label_cath = LabHomScore.out.label_network
}