#!/usr/bin/env nextflow

// Enable modules
nextflow.enable.dsl = 2

def helpMessage() {
	log.info ABIHeader()
	log.info """
	
	LAGOON-MCL

	For more information, see the documentation: https://lagoon-mcl-docs.readthedocs.io/en/latest
	=============================================================================================

	Profiles:
		-profile conda
		-profile mamba
		-profile singularity

	General parameters
		
		--help                    <bool>  true or false. Affiche cette aide

		--max_cpus                <int>   cpus max qui peut être alloué au workflow (defaul: 15)
		--max_memory              <int>   mem max qui peut être alloué au workflow (defaul: 60.GB)
		--max_time                <int    max time qui peut être alloué au workflow (default: 336.h)

   		--projectName             <str>   Name of the project 

		--fasta                   <path>  Path to fasta files
		--annotation              <path>  Path to sequence annotation files
		--pep_colname             <str>   Name of the column containing the sequence names in the annotation file(s)
		--columns_attributes      <list>  Name of the columns that will be used to annotate the networks

   		--outdir                  <path>  Path to the folder containing the results

		--concat_fasta            <str>   Name of the file that will contain all the fasta sequences

		--information             <str>
		--information_files       <paht>
		--information_attributes  <list>

		--run_diamond             <bool>  Allows you to specify whether you want to execute diamond (true or false)
		--alignment_file          <path>  Path to a file containing pairwise alignments (if --run_diamond false)
		--diamond_db              <str>   Name of the database created with the diamond makedb command

		--query                   <int>   Position of the column in the alignment file containing the query sequences
		--subject                 <int>   Position of the column in the alignment file containing the subject sequences
		--evalue                  <int>   Position of the column in the alignment file containing the evalue of the alignment between the query and subject sequences 

		--diamond                 <str>   Name of the file containing the pairwise alignment from Diamond blastp
		--sensitivity             <str>   Diamond sensitivity setting
		--matrix                  <str>   Matrix used for alignment
		--diamond_evalue          <float> Evalue used by diamond blastp

		--I                       <list>  Inflation parameter for MCL
		--max_weight              <int>   Maximum weight for edges


	Examples:

	Test parameters:
		nextflow run main.nf -profile test_full,singularity [params]
	
	Custom parameters:
		nextflow run main.nf -profile custom,singularity [params]
	"""
}

if (params.help) {
	helpMessage()
	exit 0
}

// PIPELINE INFO
// Header log info
def summary = [:]
if (workflow.revision) summary['Pipeline Release'] = workflow.revision
summary['Run Name'] = workflow.runName
summary['Project Name'] = params.projectName
summary['Output dir'] = params.outdir
summary['Launch dir'] = workflow.launchDir
summary['Working dir'] = workflow.workDir
summary['Script dir'] = workflow.projectDir
summary['User'] = workflow.userName
summary['Execution profile'] = workflow.profile

log.info summary.collect { k,v -> "${k.padRight(18)}: $v" }.join("\n")
log.info "-\033[91m--------------------------------------------------\033[0m-"

// Import modules
include { SelectLabels as SelectLabelAttrib    } from './modules/attributes.nf'
include { SelectLabels as SelectLabelInfo      } from './modules/attributes.nf'

include { InformationFiles                     } from './modules/attributes.nf'

include { LabelHomogeneityScore as LabHomScAt  } from './modules/attributes.nf'
include { LabelHomogeneityScore as LabHomScIn  } from './modules/attributes.nf'
include { LabelHomogeneityScore as HomScCath   } from './modules/attributes.nf'
include { LabelHomogeneityScore as HomScEsm    } from './modules/attributes.nf'
include { LabelHomogeneityScore as HomScAf     } from './modules/attributes.nf'

include { DiamondDB                            } from './modules/diamond.nf'
include { DiamondDB as DiamondDBAf             } from './modules/diamond.nf'
include { DiamondDB as DiamondDBEsm            } from './modules/diamond.nf'

include { DiamondBLASTp                        } from './modules/diamond.nf'
include { DiamondBLASTp as DiamondBLASTpAf   } from './modules/diamond.nf'
include { DiamondBLASTp as DiamondBLASTpEsm  } from './modules/diamond.nf'

include { FiltrationAlignments                 } from './modules/filtration.nf'
include { NetworkMcxload                       } from './modules/network.nf'
include { NetworkMcl                           } from './modules/network.nf'
include { NetworkMcxdump                       } from './modules/network.nf'
include { NetworkMclToTsv                      } from './modules/network.nf'
include { HomogeneityScore                     } from './modules/statistics.nf'
include { PlotHomogeneityScore                 } from './modules/statistics.nf'

//include { PlotHomogeneityScore as PlotHomScAll } from './modules/statistics.nf'
//include { PlotHomogeneityScore as PlotHomScAn  } from './modules/statistics.nf'
//include { PlotClusterSize                      } from './modules/statistics.nf'

include { DownloadESMatlas                     } from './modules/structure.nf'
include { DownloadAlphafoldDB                  } from './modules/structure.nf'
include { FilterStructure                      } from './modules/structure.nf'

include { HMMsearch                            } from './modules/gene3d.nf'
include { CathResolveHits                      } from './modules/gene3d.nf'
include { AssignSuperfamilies                  } from './modules/gene3d.nf'
include { SelectSuperfamilies                  } from './modules/gene3d.nf'
include { CathAnalysis                         } from './modules/gene3d.nf'

// préparation des paramètres
List<Number> list_inflation = Arrays.asList(params.I.split(","))

// Channel
proteome = Channel.fromPath(params.fasta, checkIfExists: true)
annotation_files = Channel.fromPath(params.annotation_files, checkIfExists: true)
inflation = Channel.fromList(list_inflation)

if (params.information == true) {
	information_files = Channel.fromPath(params.information_files, checkIfExists: true)
}

if (params.run_diamond == false) {
	diamond_alignment = Channel.fromPath(params.alignment_file, checkIfExists: true)
}

//if (params.scan_gene3d == false) {
//	superfamilies = Channel.fromPath(params.gene3d_aln, checkIfExists: true)
//}
/*
f (esm_aln != null && alphafold_aln == null) {

}
else if (esm_aln == null && alphafold_aln != null) {
	
}
else if (esm_aln != null && alphafold_aln != null) {

}
*/
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	RUN ALL WORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow {

	// concaténation de tous les fichiers FASTA
	
	all_sequences = proteome.collectFile(name: "all_sequences.fasta")

	/*
	CATH / Gene3D
	*/

	//if (params.run_gene3d == true) {
	if (params.scan_gene3d == true && params.gene3d_aln == null) {

		DownloadGene3D()
		hmms = DownloadGene3D.out.hmms
		cath_domain_list = DownloadGene3D.out.cath_domain_list
		discontinuous_regs = DownloadGene3D.out.discontinuous_regs

		HMMsearch(proteome, hmms)
		hmmsearch = HMMsearch.out.hmmsearch

		CathResolveHits(hmmsearch, cath_domain_list, discontinuous_regs)
		cath_resolve_hits = CathResolveHits.out.cath_resolve_hits

		AssignSuperfamilies(cath_resolve_hits)
		superfamilies = AssignSuperfamilies.out.superfamilies
	}
	else if (params.gene3d.aln != null) {
		superfamilies = Channel.fromPath(params.gene3d_aln, checkIfExists: true)
	}

	SelectSuperfamilies(superfamilies)
	select_cath = SelectSuperfamilies.out.select_cath

	cath_annotation = select_cath.collectFile(name: "${params.outdir}/cath/cath_superfamilies.csv")

	CathAnalysis(cath_annotation)
	classification = CathAnalysis.out.classification

	HomScCath(classification, "class,architecture,topology,superfamily", "sequence_id")
	cath_network = HomScCath.out.label_network

	/*
	structure prediction
	*/

	if (params.alphafold_db == true) {

		if (params.alphafold_aln == null) {
			DownloadAlphafoldDB()
			
			afSeq = DownloadAlphafoldDB.out.alfafoldSequence
			afDb = DiamondDBAf(afSeq)
			
			DiamondBLASTpAf(proteome, afDb, 'alphaFoldDBaln')
			structure_aln = DiamondBLASTpEsm.out.diamond_alignment
		}
		else if (params.alphafold_aln != null) {
			alphafold_alignment = Channel.fromPath(params.alphafold_aln, checkIfExists: true)
			structure_aln = alphafold_alignment.collectFile()
		}

		FilterStructure(structure_aln)
		structure = FilterStructure.out.structure
		
		HomScAf(structure, "alpholdDb_structure", "structure")
		structure_af_network = HomScAf.out.label_network
	}

	if (params.esm_atlas == true) {

		if (params.esm_aln == null) {
			DownloadESMatlas()

			esmSeq = DownloadESMatlas.out.esmSequence
			esmDb = DiamondDBEsm(esmSeq)
			
			DiamondBLASTpEsm(proteome, esmDb, 'esmAtlasDBaln')
			structure_aln = DiamondBLASTpEsm.out.diamond_alignment
		}
		else if (params.esm_aln != null) {
			esm_alignment = Channel.fromPath(params.esm_aln, checkIfExists: true)
			structure_aln = esm_alignment.collectFile()
		}

		FilterStructure(structure_aln)	
		structure = FilterStructure.out.structure
			
		HomScEsm(structure, "esmAtlas_structure", "structure")
		structure_esm_network = HomScEsm.out.label_network
	}

	if (params.alphafold_db == true && params.esm_atlas == false) {
		structure_network = structure_af_network.collect()
	}
	else if (params.alphafold_db == false && params.esm_atlas == true) {
		structure_network = structure_esm_network.collect()
	}
	else if (params.alphafold_db == true && params.esm_atlas == true) {
		structure_network = structure_esm_network.concat(structure_af_network).collect()
	}

	structure = cath_network.concat(structure_network).collect()

	//else if (params.alphafold_db == false && params.esm_atlas == false) {
	//}

	/*
	annotation / information
	*/

	if (params.annotation_files != null) {
		SelectLabelAttrib(annotation_files, params.annotation_attrib)
		select_annotation = SelectLabelAttrib.out.select_annotation
		select_annotation = select_annotation.collectFile(name: "${params.outdir}/network/labels/attributes.tsv")

		LabHomScAt(select_annotation, params.annotation_attrib, "attributes")
		label_network = LabHomScAt.out.label_network
	}

	if (params.information_files != null) {
	
		information_files = Channel.fromPath(params.information_files, checkIfExists: true)

		InformationFiles(proteome, information_files)
		proteome_info = InformationFiles.out.proteome_info

		SelectLabelInfo(proteome_info, params.information_attrib)
		select_info = SelectLabelInfo.out.select_annotation
		select_info = select_info.collectFile(name: "${params.outdir}/network/labels/informations.tsv")

		LabHomScIn(select_info, params.information_attrib, "information")
		info_network = LabHomScIn.out.label_network
	}

	if (params.annotation != null && params.information_files != null) {
		label_network = label_network.concat(info_network).collect()
		label_network = label_network.concat(structure).collect()
		println("A")
	} 
	else if (params.annotation == null && params.information_files != null) {
		label_network = info_network.collect()
		label_network = label_network.concat(structure).collect()
		println("B")
	}
	else if (params.annotation != null && params.information_files == null) {
		label_network = info_network.collect()
		label_network = label_network.concat(structure).collect()
		println("C")
	}
	else if (params.annotation == null && params.information_files == null) {
		label_network = structure.collect()
		label_network = label_network.concat(structure).collect()
		println("D")
	}

	/*
	run diamond
	*/
	
	if (params.run_diamond == true) {
		// diamond database
		DiamondDB(all_sequences)
		diamond_db = DiamondDB.out.diamond_db

		// diamond blastp
		DiamondBLASTp(all_sequences, diamond_db, "diamond_alignment")
		diamond_alignment = DiamondBLASTp.out.diamond_alignment	
	}
	
	FiltrationAlignments(diamond_alignment)
	diamond_ssn = FiltrationAlignments.out.diamond_ssn

	NetworkMcxload(diamond_ssn)        
	tuple_seq_dict_mci = NetworkMcxload.out.tuple_seq_dict_mci

	NetworkMcl(inflation, tuple_seq_dict_mci)
	tuple_mcl = NetworkMcl.out.tuple_mcl

	NetworkMcxdump(tuple_mcl)
	tuple_dump = NetworkMcxdump.out.tuple_dump

	NetworkMclToTsv(tuple_dump)
	tuple_network = NetworkMclToTsv.out.tuple_network

	HomogeneityScore(label_network, tuple_network)
	tuple_hom_score = HomogeneityScore.out.tuple_hom_score
	
	//tuple_hom_score_annotated = HomogeneityScore.out.tuple_hom_score_annotated

	//PlotHomScAll(tuple_hom_score_all)
	//PlotHomScAn(tuple_hom_score_annotated)

	//PlotClusterSize(tuple_network)
	//cluster_size = PlotClusterSize.out.cluster_size
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow.onComplete {

	println "- Workflow info: LAGOON-MCL workflow completed successfully -"

	log.info ABIHeader()
}

workflow.onError = {

    println "- Workflow info: LAGOON-MCL workflow completed with errors -"

	log.info ABIHeader()
}

def ABIHeader() {
	return """ 
		========================================
			  ╔═══╗ ╔═══╗   ╔═╗
			  ║╔═╗║ ║╔═╗║   ╚═╝
			  ║╚═╝║ ║╚═╝╚═╗ ╔═╗
			  ╠═══╣ ║ ╔═╗ ║ ║ ║
			  ║   ║ ║ ╚═╝ ║ ║ ║
			  ╩   ╩ ╚═════╝ ╚═╝
	              (https://bioinfo.mnhn.fr/abi/)
		========================================
	"""
	.stripIndent()
}