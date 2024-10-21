process SequenceLength {

    /*
	* Processus : Création de la banque de donnée utilisé par diamond blastp
    *
    * Input:
    * 	- séquences fasta issus de tos les fichiers fasta
    * Output:
    *	- banque de donnée construite avec toutes les séquences fasta
    */

	tag ''

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
}

process SequenceAnnotation {

	tag ''

	label 'lagoon'

	input:
		each path(label_network)
		path(sequence_length_network)

	output:
		path("${label_network.baseName}_length_network.tsv"), emit: sequence_network_length
		path("${label_network.baseName}_length_initial.tsv"), emit: sequence_initial_length

	script:
		"""
		echo ${label_network}
		echo ${sequence_length_network} 

		sequence_annotation_network.R ${sequence_length_network} ${label_network} ${label_network.baseName}

		sed '1d' ${label_network} | cut -f 1,3 | sort | uniq > ${label_network.baseName}_length_initial.tsv

		sed '1d' ${label_network} > ${label_network.baseName}_annotation_initial.tsv
		"""
}

process Test {
	
	label 'lagoon'
	
	input:
		path(annotation)

	output:
		stdout

	script:

		"""
		echo ${annotation}
		"""
}