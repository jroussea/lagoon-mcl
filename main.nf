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
			--column_query       : ${params.column_query}
			--column_subject     : ${params.column_subject}
			--column_id          : ${params.column_id}
			--column_ov          : ${params.column_ov}
			--column_ev          : ${params.column_ev}
			--filter             : ${params.filter}
			--identity           : ${params.identity}
			--overlap            : ${params.overlap}
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
if (params.filter != true && params.filter != false) {
	helpMessage()
	exit 0
}
if (!(params.identity instanceof java.lang.String)) {
	helpMessage()
	exit 0
} 
if (!(params.overlap instanceof java.lang.String)) {
	helpMessage()
	exit 0
}
if (!(params.evalue instanceof java.lang.String)) {
	helpMessage()
	exit 0
}
if (params.run_mcl != true && params.run_mcl != false) {
	helpMessage()
	exit 0
} 

// Import modules
include { RenameFastaSequences    } from './modules/preparation.nf'
include { HeaderFasta             } from './modules/preparation.nf'
include { Merge2Dataframe         } from './modules/attributes.nf'
include { Attributes              } from './modules/attributes.nf'
include { SelectInfosNodes        } from './modules/attributes.nf'
include { DiamondDB               } from './modules/diamond.nf'
include { DiamondBLASTp           } from './modules/diamond.nf'
include { OtherAlignments         } from './modules/diamond.nf'
include { FiltrationAlignedItself } from './modules/filtration.nf'
include { FiltrationAlignments    } from './modules/filtration.nf'
include { NetworkMcxload          } from './modules/network.nf'
include { NetworkMcl              } from './modules/network.nf'
include { NetworkMcxdump          } from './modules/network.nf'
include { NetworkMclToTsv         } from './modules/network.nf'
include { NetworkAddAttributes    } from './modules/network.nf'
include { HomogeneityScorePlot    } from './modules/network.nf'


// préparation des paramètres
List<Number> list_inflation = Arrays.asList(params.I.split(","))
List<Number> list_identity = Arrays.asList(params.identity.split(","))
List<Number> list_overlap = Arrays.asList(params.overlap.split(","))
List<Number> list_evalue = Arrays.asList(params.evalue.split(","))

// Channel
proteome = Channel.fromPath(params.fasta, checkIfExists: true)
annotation = Channel.fromPath(params.annotation, checkIfExists: true)
inflation = Channel.fromList(list_inflation)
id = Channel.fromList(list_identity)
ov = Channel.fromList(list_overlap)
ev = Channel.fromList(list_evalue)

if (params.run_diamond == false) {
	alignment_file = Channel.fromPath(params.alignment_file, checkIfExists: true)
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
	RenameFastaSequences(all_sequences)
	fasta_rename = RenameFastaSequences.out.fasta_rename
	//fasta_rename.view()
	cor_table = RenameFastaSequences.out.cor_table
	//cor_table.view()
	
	// récupérer les noms des des séquences fasta par fichier (fichier avant concaténation)
	HeaderFasta(proteome)
	proteome_name = HeaderFasta.out.proteome_name
	//proteome_name.view()

	// ajout d'une colonne contenant le nom de ficghier à la table d ccorrespondance précédemment créer
	Merge2Dataframe(proteome_name, cor_table)
	m2d_cor_table = Merge2Dataframe.out.m2d_cor_table
	//m2d_cor_table.view()

	// concaténation des tables de cottespondances en un seul fichier
	cor_table = m2d_cor_table.collectFile(name: "${params.outdir}/correspondence_table/correspondance_table.tsv")
	//cor_table.view()
	
	// remplacement des sont des séquences par les identifiants précédement créer dasn les fichiers d'annotation
	Attributes(m2d_cor_table, annotation)
	annot_tab = Attributes.out.annot_tab
	annot_seq_id = Attributes.out.annot_seq_id
	//annot_tab.view()

	SelectInfosNodes(annot_seq_id)
	select_annotation = SelectInfosNodes.out.select_annotation
	select_annotation.collectFile(name: "${params.outdir}/network/attributes/attributes.tsv")

	if (params.run_diamond == true) {
		// diamond database
		DiamondDB(fasta_rename)
		diamond_db = DiamondDB.out.diamond_db
		//diamond_db.view()

		// diamond blastp
		DiamondBLASTp(fasta_rename, diamond_db)
		diamond_alignment = DiamondBLASTp.out.diamond_alignment
		diamond_alignment.view()
	
	}
	if (params.run_diamond == false) {
		AttributesAlignments(cor_table, alignment_file)
		diamond_alignment = AttributesAlignments.out.diamond_alignment
	}

	// filtration des données	

	FiltrationAlignedItself(diamond_alignment)
	diamond_itself = FiltrationAlignedItself.out.diamond_itself
	diamond_itself.view()

	FiltrationAlignments(diamond_itself, id, ov, ev)
	id.view()
	tuple_diamond_ssn = FiltrationAlignments.out.tuple_diamond_ssn
	tuple_diamond_ssn.view()
	

	if (params.run_mcl == true) {

		NetworkMcxload(tuple_diamond_ssn)        
		tuple_seq_dict_mci = NetworkMcxload.out.tuple_seq_dict_mci

		NetworkMcl(inflation, tuple_seq_dict_mci)
		tuple_mcl = NetworkMcl.out.tuple_mcl

		NetworkMcxdump(tuple_mcl)
		tuple_dump = NetworkMcxdump.out.tuple_dump

		NetworkMclToTsv(tuple_dump)
		tuple_network = NetworkMclToTsv.out.tuple_network

		NetworkAddAttributes(select_annotation, tuple_network)
		tuple_hom_score = NetworkAddAttributes.out.tuple_hom_score
		//HomogeneityScorePlot(tuple_hom_score)

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
