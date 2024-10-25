process DiamondDB {

    /*
	* DESCRIPTION 
	* -----------
	* Création de la banque de donnée utilisé par diamond blastp
    *
    * INUT
	* ----
    * 	- séquences fasta issus de tos les fichiers fasta
    *
	* OUPUT
	* -----
    *	- banque de donnée construite avec toutes les séquences fasta
    */

	tag 'Diamond makedb'

	label 'diamond'


	publishDir "${params.outdir}/diamond", mode: 'copy', pattern: "${params.diamond_db}.dmnd"

	input:
		path(fasta_rename)

	output:
		path("reference.dmnd"), emit: diamond_db
	script:
		"""
    	diamond makedb --in ${fasta_rename} -d reference -p ${task.cpus}
		"""
}

process DiamondBLASTp {

    /*
	* DESCRIPTION
	* -----------
	* BLASTp toutes les séquences contre toutes les séquences
    *
    * INPUT
	* -----
    * 	- séquences fasta issus de tous les fichiers fasta
	*	- banque de donnée issus de diamond makedb
    * 
	* OUTPUT
    * ------
	*	- alignement par pair (fichier tsv)
    */

	tag 'Diamond BLASTp'
	label 'diamond'

	publishDir "${params.outdir}/diamond", mode: 'copy', pattern: "${params.diamond}"

	input:
		path(fasta_rename)
        path(diamond_db)
		val(sensitivity)
		val(diamond_evalue)
		val(matrix)

	output:
		path("diamond_alignment.tsv"), emit: diamond_alignment

	script:
		"""
    	diamond blastp -d ${diamond_db} \
    	-q ${fasta_rename} \
    	-o diamond_alignment.tsv \
    	--${sensitivity} \
    	-p ${task.cpus} \
    	-e ${diamond_evalue} \
    	--matrix ${matrix} \
		--outfmt 6 qseqid qlen qstart qend sseqid slen sstart send length pident ppos score evalue bitscore
		"""
}