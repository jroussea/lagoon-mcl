process FastaProcessing {

    /*
	* DESCRIPTION
    * -----------
    *
    * INPUT
    * -----
    * 	- 
    * OUPUT
    * -----
    *	- 
    */

    label 'lagoon'

    input:
        path(sequence)
    
    output:
		path("sequences_rename.fasta"), emit: sequence_rename
    
    script:
        """
		fasta_processing.py --fasta_input ${sequence} --fasta_output sequences_rename.fasta --processing header
        """

    stub:
		"""
		touch sequence_rename.fasta
		"""
}

process AnnotationProcessing {

    /*
	* DESCRIPTION
    * -----------
    *
    * INPUT
    * -----
    * 	- 
    * OUPUT
    * -----
    *	- 
    */

    label 'lagoon'

    input:
        each path(fasta)
        tuple val(annotation), path(file)
    
    output:
		path("label_${annotation}.tsv"), emit: label_annotation

    script:
        """
        annotation_processing.py --label ${file} --fasta ${fasta} --database ${annotation}
        """

    stub:
		"""
		touch ${annotation}.tsv
		"""
}

process FiltrationAlnNetwork {
    
	/*
	* DESCRIPTION
	* -----------
	* Suppression des séquences fasta qui n'apparaissent qu'une seul foit dans le fichier d'alignement
	* cela signifie que les séquences se sont uniquement aligné contre elle même
    *
    * INPUT
	* -----
    * 	- fichier d'alignement tsv issu de diamond balstp
    *
	* OUTPUT
	* ------
    *	- fichier d'alignement tsv
    */

	tag ''

	label 'lagoon'

    publishDir "${params.outdir}/lagoon-mcl_output/diamond", mode: 'copy', pattern: "diamond_alignment.filter.tsv"

	input:
        path(diamond_alignment)

	output:
        path("diamond_alignment.filter.tsv"), emit: diamond_ssn

	script:
		"""
        filtration_blastp.py --alignment ${diamond_alignment}
		"""

    stub:
		"""
		touch diamond_ssn.tsv
		"""
}

process NodeAnnotationProcessing {

    /*
	* DESCRIPTION
    * -----------
    *
    * INPUT
    * -----
    * 	- 
    * OUPUT
    * -----
    *	- 
    */

    label 'lagoon'

    input:
        path(fasta_file)
        each path(network)
        path(label_file)

    output:
        tuple val(network.baseName), path("node_annotation_*"), emit: tuple_node_labels

    script:
        """
        node_annotation_processing.py --network ${network} --labels ${label_file} --basename ${network.baseName} --fasta ${fasta_file}
        """
}