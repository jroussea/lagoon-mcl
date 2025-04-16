process DIAMOND_DB {

    /*
	* DESCRIPTION 
	* -----------
	* Creation of the database used by diamond blastp
    *
    * INPUT
	* -----
    * 	- fasta: fasta sequence renamed
    *
	* OUPUT
	* -----
    *	-  reference.dmnd: database built with all fasta sequences
    */

	label 'diamond'

	input:
		path(fasta)

	output:
		path("reference.dmnd"), emit: diamond_db
	
	script:
		"""
		diamond makedb --in ${fasta} -d reference -p ${task.cpus}
		"""
}

process DIAMOND_BLASTP {

    /*
	* DESCRIPTION
	* -----------
	* Alignment of all sequences against the database
    *
    * INPUT
	* -----
    * 	- fasta: fasta sequence renamed
	*	- diamond_db: diamond database
	*	- sensitivity: Diamond BLASTp sensitivity
	*	- diamond_evalue: minimum evalue
	*	- matrix: similarity matrix used by Diamond BLASTp
    * 
	* OUTPUT
    * ------
	*	- diamond_alignment.tsv: alignment file
    */

	label 'diamond'

	input:
		each path(fasta)
        path(diamond_db)
		val(sensitivity)
		val(diamond_evalue)
		val(matrix)

	output:
		path("diamond_alignment.tsv"), emit: diamond_alignment

	script:
		"""
		diamond blastp -d ${diamond_db} \
			-q ${fasta} \
			-o diamond_alignment.tsv \
			--${sensitivity} \
			-p ${task.cpus} \
			-e ${diamond_evalue} \
			--matrix ${matrix} \
			--outfmt 6 qseqid qlen qstart qend sseqid slen sstart send length pident ppos score evalue bitscore
		"""
}
