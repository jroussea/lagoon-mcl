process InformationFiles {
	
	label 'darkdino'

	input:
		each proteome
		path information_files

	output:
		//stdout
		//path "${params.concat_fasta}.rename.fasta", emit: fasta_rename
		path  "${proteome.baseName}.info", emit: proteome_info

	script:

		"""
		information_files.sh ${proteome} ${information_files} ${proteome.baseName} ${params.pep_colname}
		"""
}


process SelectLabels {

	/*
    * Processus : récupéer les colonnes contenant les informations utile pour l'annotation des réseaux
    *
    * Input:
    *	- fichier tsv contenant les annotations (informations) pour les séquences => les noms des séquences ont été remplacé par les identifiants
    * Output:
	* 	- fichier temporaire (tsv) contenant les colonnes issus des fichiers d'annotations qui vont être utilisé pour annoter les réseau
    */

	label 'darkdino'

	input:
		path annot_seq_id
		val columns_attributes

	output:
		path "${annot_seq_id.baseName}.tmp", emit: select_annotation

	script:
		"""
		select_labels.py ${annot_seq_id} ${columns_attributes} ${params.pep_colname} ${annot_seq_id.baseName}
		"""
}


process LabelHomogeneityScore {

	label 'darkdino'
	
	publishDir "${params.outdir}/network/labels/${type}", mode: 'copy', pattern: "label_*.tsv"

	input:
		path select_annotation
		val columns_attributes
		val type

	output:
		path "label_*.tsv", emit: label_network

	script:

		"""
		label_homogeneity_score.py ${select_annotation} ${columns_attributes} ${params.pep_colname}
		"""
}