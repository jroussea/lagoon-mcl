#!/usr/bin/env nextflow

// Enable modules
nextflow.enable.dsl = 2

def helpMessage() {
	log.info ABIHeader()
	log.info """
	
	LAGOON-MCL v1.0.0

	For more information, see the documentation: https://github.com/jroussea/LAGOON-MCL/wiki/
	=========================================================================================

	Test parameters:
		nextflow run main.nf -profile test_full,singularity [params]
	
	Custom parameters:
		nextflow run main.nf -profile custom,singularity [params]

	General parameters
		Mandatory parameters
			--fasta                 Path to fasta files
			--annotation            Path to sequence annotation files
			--pep_colname           Name of the column containing the sequence names in the annotation file(s)
			--columns_attributes    Name of the columns that will be used to annotate the networks
		Optional parameters
    		--projectName           Name of the project 
    		--outdir                Path to the folder containing the results
			--concat_fasta          Name of the file that will contain all the fasta sequences

	Alignment parameters
		LAGOON-MCL parameters
			--run_diamond           Allows you to specify whether you want to execute diamond (true or false)
			--alignment_file        Path to a file containing pairwise alignments (if --run_diamond false)
			--column_query          Position of the column in the alignment file containing the query sequences
			--column_subject        Position of the column in the alignment file containing the subject sequences
			--column_id             Position of the column in the alignment file containing the percent identity between the query and subject sequences
			--column_ov             Position of the column in the alignment file containing the percentage of overlap between the query and subject sequences 
			--column_ev             Position of the column in the alignment file containing the evalue of the alignment between the query and subject sequences 
			--filter                Alignment filtration can be done based on identity an overlap percentages and evalue (true or false)
			--identity              Identity percentage
			--overlap               Overlap percentage
			--evalue                Evalue
		Diamond parameters
			--diamond               Name of the file containing the pairwise alignment from Diamond blastp
			--diamond_db            Name of the database created with the diamond makedb command
			--sensitivity           Diamond sensitivity setting
			--matrix                Matrix used for alignment
			--diamond_evalue        Evalue used by diamond blastp

	Network parameters
			--run_mcl               Running Markov CLustering algorithm (true or false)
			--I                     Inflation parameter for MCL
			--max_weight            Maximum weight for edges

	"""
}

def logInformations() {
	log.info """\
	LAGOON-MCL - ANALYSIS PARAMETERS
	===================================================
	General parameters
		Mandatory parameters
			--fasta              : ${params.fasta}
			--annotation         : ${params.annotation}
			--pep_colname        : ${params.pep_colname}
			--columns_attributes : ${params.columns_attributes}
		Optional parameters
    		--projectName        : ${params.projectName}
    		--outdir             : ${params.outdir}
			--concat_fasta       : ${params.concat_fasta}

	Alignment parameters
		LAGOON-MCL parameters
			--run_diamond        : ${params.run_diamond}
			--alignment_file     : ${params.alignment_file}
			--evalue             : ${params.evalue}
		Diamond parameters
			--diamond            : ${params.diamond}
			--diamond_db         : ${params.diamond_db}
			--sensitivity        : ${params.sensitivity}
			--matrix             : ${params.matrix}
			--diamond_evalue     : ${params.diamond_evalue}

	Network parameters
			--run_mcl            : ${params.run_mcl}
			--I                  : ${params.I}
			--max_weight         : ${params.max_weight}
	"""
}

logInformations()

/*
Test des paramètres
si ne rempli pas les conditions renvoi un message d'erreur
*/

if (params.help) {
	helpMessage()
	exit 0
}
if (!(params.projectName instanceof java.lang.String)) {
	helpMessage()
	exit 0
}
if (!(params.tmpFile instanceof java.lang.String)) {
	helpMessage()
	exit 0
}
if (!(params.fasta instanceof java.lang.String)) {
	helpMessage()
	exit 0
}
if (!(params.annotation instanceof java.lang.String)) {
	helpMessage()
	exit 0
}
if (!(params.pep_colname instanceof java.lang.String)) {
	helpMessage()
	exit 0
}
if (!(params.columns_attributes instanceof java.lang.String)) {
	helpMessage()
	exit 0
}
if (!(params.concat_fasta instanceof java.lang.String)) {
	helpMessage()
	exit 0
}
if (!(params.outdir instanceof java.lang.String)) {
	helpMessage()
	exit 0
}
if (!(params.diamond_db instanceof java.lang.String)) {
	helpMessage()
	exit 0
}
if (!(params.diamond instanceof java.lang.String)) {
	helpMessage()
	exit 0
}
if (params.sensitivity != "fast"
	&& params.sensitivity != "mid-sensitive"
	&& params.sensitivity != "more-sensitive"
	&& params.sensitivity != "very-sensitive"
	&& params.sensitivity != "sensitive"
	&& params.sensitivity != "ultra-sensitive"
	|| !(params.sensitivity instanceof java.lang.String)) {
	helpMessage()
	exit 0
}
if (params.matrix != "BLOSUM45"
	&& params.matrix != "BLOSUM50"
	&& params.matrix != "BLOSUM62"
	&& params.matrix != "BLOSUM80"
	&& params.matrix != "BLOSUM90"
	&& params.matrix != "PAM250"
	&& params.matrix != "PAM70"
	&& params.matrix != "PAM30"
	|| !(params.matrix instanceof java.lang.String)) {
	helpMessage()
	exit 0
}
if (params.diamond_evalue instanceof java.lang.String
	|| params.diamond_evalue > 1 || params.diamond_evalue < 0) {
	helpMessage()
	exit 0
}
if (params.run_mcl != true && params.run_mcl != false) {
	helpMessage()
	exit 0
} 

// Import modules
include { HeaderFasta                          } from './modules/preparation.nf'
include { SelectLabels                         } from './modules/attributes.nf'
include { LabelHomogeneityScore                } from './modules/attributes.nf'
include { DiamondDB                            } from './modules/diamond.nf'
include { DiamondBLASTp                        } from './modules/diamond.nf'
include { FiltrationAlignments                 } from './modules/filtration.nf'
include { NetworkMcxload                       } from './modules/network.nf'
include { NetworkMcl                           } from './modules/network.nf'
include { NetworkMcxdump                       } from './modules/network.nf'
include { NetworkMclToTsv                      } from './modules/network.nf'
include { HomogeneityScore                     } from './modules/statistics.nf'
include { PlotHomogeneityScore as PlotHomScAll } from './modules/statistics.nf'
include { PlotHomogeneityScore as PlotHomScAn  } from './modules/statistics.nf'
include { PlotClusterSize                      } from './modules/statistics.nf'

// préparation des paramètres
List<Number> list_inflation = Arrays.asList(params.I.split(","))

// Channel
proteome = Channel.fromPath(params.fasta, checkIfExists: true)
annotation = Channel.fromPath(params.annotation, checkIfExists: true)
inflation = Channel.fromList(list_inflation)

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
	
	HeaderFasta(all_sequences)
	fasta_rename = HeaderFasta.out.fasta_rename

	SelectLabels(annotation)
	select_annotation = SelectLabels.out.select_annotation
	select_annotation = select_annotation.collectFile(name: "${params.outdir}/network/attributes/attributes.tsv")

	LabelHomogeneityScore(select_annotation)
	label_network = LabelHomogeneityScore.out.label_network
	label_network = label_network.collect()

	if (params.run_diamond == true) {
		// diamond database
		DiamondDB(fasta_rename)
		diamond_db = DiamondDB.out.diamond_db

		// diamond blastp
		DiamondBLASTp(fasta_rename, diamond_db)
		diamond_alignment = DiamondBLASTp.out.diamond_alignment	
	}

	FiltrationAlignments(diamond_alignment)
	diamond_ssn = FiltrationAlignments.out.diamond_ssn
	
	if (params.run_mcl == true) {

		NetworkMcxload(diamond_ssn)        
		tuple_seq_dict_mci = NetworkMcxload.out.tuple_seq_dict_mci

		NetworkMcl(inflation, tuple_seq_dict_mci)
		tuple_mcl = NetworkMcl.out.tuple_mcl

		NetworkMcxdump(tuple_mcl)
		tuple_dump = NetworkMcxdump.out.tuple_dump

		NetworkMclToTsv(tuple_dump)
		tuple_network = NetworkMclToTsv.out.tuple_network

		HomogeneityScore(label_network, tuple_network)
		tuple_hom_score_all = HomogeneityScore.out.tuple_hom_score_all
		tuple_hom_score_annotated = HomogeneityScore.out.tuple_hom_score_annotated
		//tuple_hom_score.view()

		PlotHomScAll(tuple_hom_score_all)
		PlotHomScAn(tuple_hom_score_annotated)

		PlotClusterSize(tuple_network)
	}
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
