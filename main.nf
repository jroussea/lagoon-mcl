#!/usr/bin/env nextflow

// Enable modules
nextflow.enable.dsl = 2

def helpMessage() {
	log.info ABIHeader()
	log.info """
	LAGOON-MCL project: Annotation fonctionnelle
	
	- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	
	Description: Nextflow workflow pour faire de l'annotation fonctionnelle
	
	=============================================================================


			The typical command to run the pipeline is:
				nextflow run main.nf -c nextflow.config -profile custom,singularity [params]
	



		Setting [params]
	Mandatory:
	Optional:

	"""
}

def logInformations() {
	log.info """\
	LAGOON-MCL
	===================================================
	General informations
		projectName                 : ${params.projectName}
		fasta                       : ${params.fasta}
		annotation                  : ${params.annotation}
		concatenated fasta files    : ${params.concat_fasta}
	
	Diamond informations
		diamond database            : ${params.diamond_db}
		diamond alignment           : ${params.diamond}
		sensitivity (blastp)        : ${params.sensitivity}
		matrix (blastp)             : ${params.matrix}
		evalue (blastp)             : ${params.evalue}
		
	Diamond pairwise alignment analysis
		Filtering alignments        : ${params.filter}
		minimum identity percentage : ${params.flt_id}
		minimum overlap percentage  : ${params.flt_ov}
		evalue maximum              : ${params.flt_ev}


		${params.run_mcl}
	"""
}

logInformations()


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
if (params.evalue instanceof java.lang.String
	|| params.evalue > 1 || params.evalue < 0) {
	helpMessage()
	exit 0
}
if (params.filter != true && params.filter != false) {
	helpMessage()
	exit 0
}
if (params.flt_id instanceof java.lang.String
	|| params.flt_id > 100 || params.flt_id < 0) {
	helpMessage()
	exit 0
} 
if (params.flt_ov instanceof java.lang.String
	|| params.flt_ov > 100 || params.flt_ov < 0) {
	helpMessage()
	exit 0
}
if (params.flt_ev instanceof java.lang.String
	|| params.flt_ev > 1 || params.flt_ev < 0) {
	helpMessage()
	exit 0
}
if (params.run_mcl != true && params.run_mcl != false) {
	helpMessage()
	exit 0
} 

// Import modules
include { RenameFastaSequences    } from './modules/data_preparation.nf'
include { HeaderFasta             } from './modules/data_preparation.nf'
include { Merge2Dataframe         } from './modules/attributes.nf'
include { Attributes              } from './modules/attributes.nf'
include { SelectInfosNodes        } from './modules/attributes.nf'
include { DiamondDB               } from './modules/diamond.nf'
include { DiamondBLASTp           } from './modules/diamond.nf'
include { FiltrationAlignments    } from './modules/filtration_alignments.nf'
include { FiltrationAlignedItself } from './modules/filtration_alignments.nf'
include { NetworkMcxload          } from './modules/network.nf'
include { NetworkMcl              } from './modules/network.nf'
include { NetworkMcxdump          } from './modules/network.nf'
include { NetworkMclToTsv         } from './modules/network.nf'
include { NetworkAddAttributes    } from './modules/network.nf'
include { Test    } from './modules/network.nf'

/*
In development

//include { JsonGeneralInformations } from './modules/json.nf'
//include { JsonSequenceInformation } from './modules/json.nf'
*/

// préparation des liste de paramètre
List<Number> list_inflation = Arrays.asList(params.I.split(","))
List<Number> list_identity = Arrays.asList(params.test_id.split(","))
List<Number> list_overlap = Arrays.asList(params.test_ov.split(","))
List<Number> list_evalue = Arrays.asList(params.test_ev.split(","))

// Channel
proteome = Channel.fromPath(params.fasta, checkIfExists: true)
annotation = Channel.fromPath(params.annotation, checkIfExists: true)
//inflation = Channel.of(params.I1, params.I2, params.I3).filter(Number)
inflation = Channel.fromList(list_inflation)
id = Channel.fromList(list_identity)
ov = Channel.fromList(list_overlap)
ev = Channel.fromList(list_evalue)

/*
In development

// string to list
List<String> list_column = Arrays.asList(params.columns_attributes.split(","))
nodes_infos = Channel.fromList(list_column)
*/

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

	/*
	Creation of JSON file for storing information.
	In development.

	JsonGeneralInformations(m2d_cor_table)
	json_file = Channel.fromPath("${params.tmpFile}/json")
	json_file.view()
	JsonSequenceInformation(json_file, annotation, annot_tab)
	*/

	// diamond database
	DiamondDB(fasta_rename)
	diamond_db = DiamondDB.out.diamond_db
	//diamond_db.view()

	// diamond blastp
	DiamondBLASTp(fasta_rename, diamond_db)
	diamond_alignment = DiamondBLASTp.out.diamond_alignment

	//diamond_alignment.view()

	// filtration des données
	FiltrationAlignedItself(diamond_alignment)
	diamond_itself = FiltrationAlignedItself.out.diamond_itself
	FiltrationAlignments(diamond_itself, id, ov, ev)
	diamond_ssn = FiltrationAlignments.out.diamond_ssn
	tuple_diamond_ssn = FiltrationAlignments.out.tuple_diamond_ssn

	if (params.run_mcl == true) {

		NetworkMcxload(tuple_diamond_ssn)
		//seq_dict = NetworkMcxload.out.seq_dict
		//seq_mci = NetworkMcxload.out.seq_mci

		//tuple_seq_dict = NetworkMcxload.out.tuple_seq_dict
		//tuple_seq_mci = NetworkMcxload.out.tuple_seq_mci
        
		tuple_seq_dict_mci = NetworkMcxload.out.tuple_seq_dict_mci

		NetworkMcl(inflation, tuple_seq_dict_mci)
		//out_seq_mcl = NetworkMcl.out.out_seq_mcl
		//tuple_out_seq_mcl = NetworkMcl.out.tuple_out_seq_mcl

		tuple_mcl = NetworkMcl.out.tuple_mcl

		NetworkMcxdump(tuple_mcl)
		tuple_dump = NetworkMcxdump.out.tuple_dump
		//network_mcl.view()

		NetworkMclToTsv(tuple_dump)
		tuple_network = NetworkMclToTsv.out.tuple_network

		SelectInfosNodes(annot_seq_id)
		select_annotation = SelectInfosNodes.out.select_annotation
		select_annotation.collectFile(name: "${params.outdir}/network/attributes/attributes.tsv")

		NetworkAddAttributes(select_annotation, tuple_network)

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
