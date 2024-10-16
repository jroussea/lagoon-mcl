process DiamondDB {

    /*
	* Processus : Création de la banque de donnée utilisé par diamond blastp
    *
    * Input:
    * 	- séquences fasta issus de tos les fichiers fasta
    * Output:
    *	- banque de donnée construite avec toutes les séquences fasta
    */

	tag 'Diamond makedb'

	label 'diamond'


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

	tag 'Diamond BLASTp'
	label 'diamond'

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
		--outfmt 6 qseqid qlen qstart qend sseqid slen sstart send length pident ppos score evalue bitscore
		"""
}

process FiltrationAlnNetwork {
    
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
		filtration_diamond_blastp_network.sh ${diamond_alignment}
		"""
}

process FiltrationAlnStructure {
    
    tag ''

	label 'lagoon'

	//publishDir "${params.outdir}", mode: 'copy', pattern: "${structure_aln.baseName}_alignment.tsv"

    input:
        path structure_aln

    output:
        path "${structure_aln.baseName}_alignment.tsv", emit: structure

    script:
        """
        cut -f 1,5,10,13 ${structure_aln} > structure.aln

        filtration_diamond_blastp_structure.py structure.aln

        cut -f 1 filter_*.aln > col1 
        cut -f 2 filter_*.aln > col2

        paste col2 col1 > ${structure_aln.baseName}_alignment.tsv
        """
}

/*
process DiamondBLASTpStructure {
	
	tag 'Diamond BLASTp'

	label 'diamond'

	//publishDir "${params.outdir}/diamond/${name}", mode: 'copy', pattern: "${name}.tsv"

	input:
		path fasta_rename
        path diamond_db
		//val name

	output:
		path "${fasta_rename.baseName}_alignment.tsv", emit: diamond_alignment

	script:
		"""
    	diamond blastp \
		-d ${diamond_db} \
    	-q ${fasta_rename} \
    	-o ${fasta_rename.baseName}_alignment.tsv \
    	--${params.sensitivity} \
    	-p ${task.cpus} \
    	-e ${params.diamond_evalue} \
    	--matrix ${params.matrix} \
		--outfmt 6 qseqid sseqid pident evalue
		"""
}
*/
