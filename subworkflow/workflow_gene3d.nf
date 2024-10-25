#!/usr/bin/env nextflow

// Enable modules
nextflow.enable.dsl = 2

/* CATH / Gene3D */

include { DownloadGene3D      } from '../modules/download.nf'
include { HMMsearch           } from '../modules/hmmer.nf'
include { CathResolveHits     } from '../modules/gene3d.nf'
include { AssignSuperfamilies } from '../modules/gene3d.nf'
include { SelectSuperfamilies } from '../modules/gene3d.nf'
include { CathAnalysis        } from '../modules/gene3d.nf'
include { PreparationCath     } from '../modules/gene3d.nf'

workflow GENE3D {
    
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
        gene3d_aln
        proteome

    main:
        if (gene3d_aln == null) {

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

            HMMsearch(proteome, hmms, params.Z, params.domE, params.incdomE)
            hmmsearch = HMMsearch.out.hmmsearch

            CathResolveHits(hmmsearch)
            cath_resolve_hits = CathResolveHits.out.cath_resolve_hits

            AssignSuperfamilies(cath_resolve_hits, cath_domain_list, discontinuous_regs)
            superfamilies = AssignSuperfamilies.out.superfamilies

            SelectSuperfamilies(superfamilies)
            select_cath = SelectSuperfamilies.out.select_cath
        
            cath_annotation = select_cath.collectFile(name: "${params.outdir}/cath/cath_superfamilies.csv")

        }
        else if (gene3d_aln != null) {
            cath_annotation = Channel.fromPath(gene3d_aln, checkIfExists: true)
        }

        CathAnalysis(cath_annotation)
        classification = CathAnalysis.out.classification

        PreparationCath(classification, "class,architecture,topology,superfamily", "sequence_id")

    emit:
        label_cath = PreparationCath.out.label_cath.collect()
}