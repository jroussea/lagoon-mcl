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
include { DiamondDB                            } from './modules/diamond.nf'
include { DiamondBLASTp                        } from './modules/diamond.nf'
include { FiltrationAlignments                 } from './modules/filtration.nf'
include { NetworkMcxload                       } from './modules/network.nf'
include { NetworkMcl                           } from './modules/network.nf'
include { NetworkMcxdump                       } from './modules/network.nf'
include { NetworkMclToTsv                      } from './modules/network.nf'
include { HomogeneityScore                     } from './modules/statistics.nf'
include { PlotHomogeneityScore                 } from './modules/statistics.nf'
//include { PlotHomogeneityScore as PlotHomScAll } from './modules/statistics.nf'
//include { PlotHomogeneityScore as PlotHomScAn  } from './modules/statistics.nf'
include { PlotClusterSize                      } from './modules/statistics.nf'

// préparation des paramètres
List<Number> list_inflation = Arrays.asList(params.I.split(","))

// Channel
proteome = Channel.fromPath(params.fasta, checkIfExists: true)
annotation = Channel.fromPath(params.annotation, checkIfExists: true)
inflation = Channel.fromList(list_inflation)

if (params.information == true) {
	information_files = Channel.fromPath(params.information_files, checkIfExists: true)
}

if (params.run_diamond == false) {
	diamond_alignment = Channel.fromPath(params.alignment_file, checkIfExists: true)
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	RUN ALL WORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow{

	// concaténation de tous les fichiers fasta 
	// concaténer tous les fichiers fasta en un seul et renommer les séquences de la mannière suivante seq1, seq2, ..., seq100, ... 
	// créer une table de correspondance
	all_sequences = proteome.collectFile(name: "${params.concat_fasta}.fasta")

	SelectLabelAttrib(annotation, params.columns_attributes)
	select_annotation = SelectLabelAttrib.out.select_annotation
	select_annotation = select_annotation.collectFile(name: "${params.outdir}/network/labels/attributes.tsv")

	LabHomScAt(select_annotation, params.columns_attributes, "attributes")
	label_network = LabHomScAt.out.label_network

	if (params.information == true) {
		InformationFiles(proteome, information_files)
		proteome_info = InformationFiles.out.proteome_info

		SelectLabelInfo(proteome_info, params.information_attributes)
		select_info = SelectLabelInfo.out.select_annotation
		select_info = select_info.collectFile(name: "${params.outdir}/network/labels/informations.tsv")

		LabHomScIn(select_info, params.information_attributes, "information")
		info_network = LabHomScIn.out.label_network

		label_network = label_network.concat(info_network).collect()
	}
	else if (params.information == false) {
		label_network = label_network.collect()
	}

	if (params.run_diamond == true) {
		// diamond database
		DiamondDB(all_sequences)
		diamond_db = DiamondDB.out.diamond_db

		// diamond blastp
		DiamondBLASTp(all_sequences, diamond_db)
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

	PlotHomogeneityScore(tuple_hom_score)
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

