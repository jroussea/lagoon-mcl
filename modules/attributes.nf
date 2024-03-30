process Merge2Dataframe {

	/*
    * Processus : création d'une table de correspondance entre les header et les identifiants des séquences pour chaque fichier fasta en input
    *
    * Input:
    * 	- fichier texte contenant les noms des séquences fasta
	*	- table de correspondance contenant le nom et les identifiant de toutes les séquences fasta
    * Output:
    *	- table de correspondance par fichier
    */

	label "darkdino"
	
	input:
        each proteome_name
        path cor_table

	output:
        path "${proteome_name.baseName}.id_tsv", emit: m2d_cor_table

	script:
		"""
    	merge_2_dataframe.py ${proteome_name.baseName} ${proteome_name} ${cor_table}
		"""
}

process Attributes {

	/*
    * Processus : création d'une table de correspondance entre les header et les identifiants des séquences pour chaque fichier fasta en input
    *
    * Input:
    * 	- table de correspondance contenant le nom et les identifiant de toutes les séquences fasta
	*	- fichier tsv contenant les annotations (informations) pour les séquences
    * Output:
	* 	- ajout des nom des séquence provenant des fichiers d'annotations dans la table de corresmpondance
    *	- fichier tsv contenant les annotations (informations) pour les séquences => les noms des séquences ont été remplacé par les identifiants
    */

	label "darkdino"

	input:
		each m2d_cor_table
        path annotation

	output:
		path "${m2d_cor_table.baseName}.tab", emit: annot_tab
		path "${m2d_cor_table.baseName}.sequence_id_tsv", emit: annot_seq_id

	script:
		"""
		attributes.sh ${m2d_cor_table} ${annotation}/${m2d_cor_table.baseName}.tsv ${m2d_cor_table.baseName}
	
		attributes.py ${m2d_cor_table.baseName}.tab ${annotation}/${m2d_cor_table.baseName}.tsv ${params.pep_colname} ${m2d_cor_table.baseName}
		"""
}

process SelectInfosNodes {

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

	output:
		path "${annot_seq_id.baseName}.tmp", emit: select_annotation

	script:
		"""
		select_infos_nodes.py ${annot_seq_id} "${params.columns_attributes}" ${annot_seq_id.baseName}
		"""
}