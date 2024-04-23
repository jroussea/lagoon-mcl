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

	publishDir "${params.outdir}/network/attributes", mode: 'copy', pattern: "label_*.tsv"

	input:
		path annot_seq_id

	output:
		path "${annot_seq_id.baseName}.tmp", emit: select_annotation

	script:
		"""
		select_labels.py ${annot_seq_id} ${params.columns_attributes} ${params.pep_colname} ${annot_seq_id.baseName}
		"""
}

process LabelHomogeneityScore {

	label 'darkdino'
	
	publishDir "${params.outdir}/network/attributes/labels", mode: 'copy', pattern: "label_*.tsv"

	input:
		path select_annotation

	output:
		path "label_*.tsv", emit: label_network

	script:

		"""
		label_homogeneity_score.py ${select_annotation} ${params.columns_attributes} ${params.pep_colname}
		"""
}