process InformationFiles {
	
	tag ''
	
	label 'lagoon'

	input:
		each proteome
		path information_files

	output:
		//stdout
		//path "${params.concat_fasta}.rename.fasta", emit: fasta_rename
		path  "${proteome.baseName}.info.tsv", emit: proteome_info

	script:

		"""
		information_for_all_sequences.sh ${proteome} ${information_files} ${proteome.baseName} ${params.peptides_column}

		sequence_information_selection.py ${proteome.baseName}.info ${params.peptides_column} ${params.information_attrib}
		"""
}

process LabInformation {

	tag ''

	label 'lagoon'


	publishDir "${params.outdir}/network/", mode: 'copy', pattern: "*.tsv"

	input:
		path information

	output:
		path "*.tsv", emit: label_network

	script:

		"""
		
		one_tsv_per_information.py ${information} ${params.peptides_column} ${params.information_attrib}

		"""
}

/*
process SelectLabels {

	
    * Processus : récupéer les colonnes contenant les informations utile pour l'annotation des réseaux
    *
    * Input:
    *	- fichier tsv contenant les annotations (informations) pour les séquences => les noms des séquences ont été remplacé par les identifiants
    * Output:
	* 	- fichier temporaire (tsv) contenant les colonnes issus des fichiers d'annotations qui vont être utilisé pour annoter les réseau
    

	
	tag ''

	label 'lagoon'

	input:
		path annot_seq_id
		val columns_attributes

	output:
		path "${annot_seq_id.baseName}.tmp", emit: select_annotation

	script:
		"""
		select_labels.py ${annot_seq_id} ${columns_attributes} ${params.peptides_column} ${annot_seq_id.baseName}
		"""
}
*/

process LabHomScore {

	tag ''

	label 'lagoon'


	publishDir "${params.outdir}/network/labels/${type}", mode: 'copy', pattern: "*.tsv"

	input:
		path select_annotation
		val columns_attributes
		val type

	output:
		path "*.tsv", emit: label_network

	script:

		"""
		label_homogeneity_score.py ${select_annotation} ${columns_attributes} ${params.peptides_column}
		"""
}


