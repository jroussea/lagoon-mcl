process FiltrationAlignments {
    
	publishDir "${params.outdir}/diamond", mode: 'copy', pattern: 'diamond_ssn.tsv'
	/*
	* Processus : suppression des séquences fasta qui n'apparaissent qu'une seul foit dans le fichier d'alignement
	* cela signifie que les séquences se sont uniquement aligné contre elle même
    *
    * Input:
    * 	- fichier d'alignement tsv issu de diamond balstp
    * Output:
    *	- fichier d'alignement tsv
    */

	tag ''

	label 'lagoon'

	input:
        path diamond_alignment

	output:
        path "diamond_ssn.tsv", emit: diamond_ssn

	script:
		"""
		test.sh ${diamond_alignment}
		"""
}