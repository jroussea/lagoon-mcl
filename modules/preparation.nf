process PreparationFasta {

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
	
    label 'seqkit'

    publishDir "${params.outdir}/diamond/", mode: 'copy', pattern: "sequence_rename.fasta"

    input:
        path(sequence)
    
    output:
		path("sequence_rename.fasta"), emit: sequence_rename
    
    script:
        """
		multi_line_to_single_line.sh ${sequence}

        seqkit seq -i one_line.fasta > sequence_rename.fasta
        """
}

process PreparationAnnot {

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

    publishDir "${params.outdir}/annotation/", mode: 'copy', pattern: "${annotation.baseName}.tsv"
    
    input:
        path(annotation)
    
    output:
        //stdout
		path("${annotation.baseName}.tsv"), emit: label_annotation
    
    script:
        """
		mv ${annotation} intermediate

        label_annotation.R intermediate ${annotation.baseName}
        """

    stub:
		"""
        touch ${annotation.baseName}.tsv
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

	input:
        path(diamond_alignment)

	output:
        path("diamond_ssn.tsv"), emit: diamond_ssn

	script:
		"""
		filtration_diamond_blastp_network.sh -a ${diamond_alignment}
		"""

    stub:
		"""
        touch diamond_ssn.tsv
		"""
}

process SequenceLength {

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

	label 'seqkit'

	input:
		path fasta
		path diamond_ssn

	output:
		path("sequence_length.tsv"), emit: sequence_length
		path("sequence_length_network.tsv"), emit: sequence_length_network

	script:
		"""
		seqkit fx2tab ${fasta} -l -n -i > sequence_length.tsv
		
		cut -f 1 ${diamond_ssn} > query
		cut -f 2 ${diamond_ssn} > subject

		cat query subject | sort | uniq > sequence_network.lst

		seqkit grep -f sequence_network.lst ${fasta} -o sequence_network.fasta

		seqkit fx2tab sequence_network.fasta -l -n -i > sequence_length_network.tsv
		"""


    stub:
		"""
        touch sequence_length.tsv
        touch sequence_length_network.tsv
		"""
}

process SequenceAnnotation {

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
		each path(label_network)
		path(sequence_length_network)

	output:
		path("${label_network.baseName}_annotation_network.tsv"), emit: annotation_network
		path("${label_network.baseName}_length_network.tsv"), emit: length_annotation

	script:
		"""
		echo ${label_network}
		echo ${sequence_length_network} 

		sequence_annotation_network.R ${sequence_length_network} ${label_network} ${label_network.baseName}

		sed '1d' ${label_network} | cut -f 1,3 | sort | uniq > ${label_network.baseName}_length_initial.tsv

		sed '1d' ${label_network} > ${label_network.baseName}_annotation_initial.tsv
		"""

    stub:
		"""
        touch ${label_network.baseName}_annotation_network.tsv
        touch ${label_network.baseName}_length_network.tsv
		"""
}