process DiamondDB {

    /*
	* Processus : Création de la banque de donnée utilisé par diamond blastp
    *
    * Input:
    * 	- séquences fasta issus de tos les fichiers fasta
    * Output:
    *	- banque de donnée construite avec toutes les séquences fasta
    */

	label "diamond"

	publishDir "${params.outdir}/diamond", mode: 'copy', pattern: "${params.diamond_db}.dmnd"

	input:
		path fasta_rename

	output:
        path "${params.diamond_db}.dmnd", emit: diamond_db

	script:
		"""
    	diamond makedb --in ${fasta_rename} -d ${params.diamond_db} -p ${task.cpus}
		"""
}

process DiamondBLASTp {

    /*
	* Processus :BLASTp toutes les séquences contre toutes les séquences
    *
    * Input:
    * 	- séquences fasta issus de tous les fichiers fasta
	*	- banque de donnée issus de diamond makedb
    * Output:
    *	- alignement par pair (fichier tsv)
    */

	label "diamond"

	publishDir "${params.outdir}/diamond", mode: 'copy', pattern: "${params.diamond}"

	input:
		path fasta_rename
        path diamond_db

	output:
        path "${params.diamond}", emit: diamond_alignment

	script:
		"""
    	diamond blastp -d ${diamond_db} \
    	-q ${fasta_rename} \
    	-o ${params.diamond} \
    	--${params.sensitivity} \
    	-p ${task.cpus} \
    	-e ${params.diamond_evalue} \
    	--matrix ${params.matrix} \
		--outfmt 6 qseqid sseqid pident ppos length mismatch gapopen qstart qend sstart send evalue bitscore
		"""
}

process OtherAlignments {

	/*
    * Processus : 
    *
    * Input:
    * 	- 
    * Output:
	* 	- 
	*/

	label "darkdino"

	input:
		path cor_table
        path alignment_file

	output:
		path "*.tsv", emit: diamond_alignment

	script:
		"""
		attributes_alignments.sh ${cor_table} ${alignment_file} ${params.column_query} ${params.column_subject}
	
		attributes_alignments.R column_query.tab column_subject.tab ${alignment_file} ${params.column_query} ${params.column_subject}
		"""
}