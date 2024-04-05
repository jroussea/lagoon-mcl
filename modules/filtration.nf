process FiltrationAlignedItself {
    
	/*
	* Processus : suppression des séquences fasta qui n'apparaissent qu'une seul foit dans le fichier d'alignement
	* cela signifie que les séquences se sont uniquement aligné contre elle même
    *
    * Input:
    * 	- fichier d'alignement tsv issu de diamond balstp
    * Output:
    *	- fichier d'alignement tsv
    */

	label 'darkdino'

	input:
        path diamond_alignment

	output:
        path "*.itself_tsv", emit: diamond_itself

	script:
	"""
    filtration_alignment.py ${diamond_alignment} ${diamond_alignment.baseName}
	"""
}

process FiltrationAlignments {

    /*
	* Processus : filtration des alignements issus de diamond blastp en fonction d'un seuilminimal pour le pourcentage d'identité, le pourcentage d'overlap et la evalue
	* il est possible de ne pas faire cette filtration
    * création d'un pdf contenant des plots pour visualiser la distribution des pourcentage d'identité, pourcentaghe d'overlap et evalue
	*
    * Input:
    * 	- fichier d'alignement tsv issu de diamond blastp
	*	- paramètre du pourcentage d'identité (id) pourcentage overlap (ov) et evalue (ev)
	*	  réalise toute les combinaison possible entre les paramètre indiqué
	*
    * Output:
    *	- fichier d'alignement tsv filtré
	*	- fichier pdf contenant 3 plots avec la distribution des identidité overlap evalue
	*		-> dans le cas ou la filtration est faite 2 pdf sont généré, le premier avant la filtration, le deuxième après la filtration
	*			permet ainsi lacomparaisont
	*		-> dans le cas ou la filtraiton n'est pas réalisé un seul pdf est généré
    */

	label 'darkdino'

	publishDir "${params.outdir}/diamond", mode: 'copy', pattern: 'diamond_ssn*.tsv'
	publishDir "${params.outdir}/distribution", mode: 'copy', pattern: "*.pdf"

	input:
        path diamond_itself
		each id
		each ov
		each ev

	output:
        path "*.pdf"
		tuple path("diamond_ssn*.tsv"), val("${condition}"), emit: tuple_diamond_ssn

	script:

		if ("${params.filter}" == true) {
			condition = "${id}_${ov}_${ev}"
			//println("${condition}")
		}
		if ("${params.filter}" == false) {
			condition = "without_filtration"
			//println("${condition}")
		}
		
		"""
    	filtration_alignments.R ${diamond_itself} ${id} ${ov} ${ev} ${params.filter} ${params.column_query} ${params.column_subject} ${params.column_id} ${params.column_ov} ${params.column_ev}
		"""
}
