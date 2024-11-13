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

    publishDir "${params.outdir}/lagoon-mcl_output/diamond/", mode: 'copy', pattern: "sequence_rename.fasta"

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

    publishDir "${params.outdir}/lagoon-mcl_output/annotation/", mode: 'copy', pattern: "${annotation.baseName}.tsv"
    
    input:
        path(annotation)
    
    output:
        //stdout
		path("${annotation.baseName}.tsv"), emit: label_annotation
    
    script:
        """
		mv ${annotation} intermediate

        add_column.sh -i intermediate -o ${annotation.baseName}.tsv -c ${annotation.baseName}
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
}

process SeqLength {

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

	publishDir "${params.outdir}/lagoon-mcl_reports/data/sequences_and_clusters/", mode: 'copy', pattern: "sequence_length.tsv"

	input:
		path fasta

	output:
		path("sequence_length.tsv"), emit: sequence_length

	script:
		"""
		seqkit fx2tab ${fasta} -l -n -i > sequence_length.tsv
		"""
}

process SeqLengthCluster {

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
		tuple path(network), val(inflation), path(fasta)

	output:
		path("${network.baseName}_length.tsv"), emit: network_length

	script:
		"""		
		cut -f 2 ${network} > sequence.lst

		seqkit grep -f sequence.lst ${fasta} -o sequence.faa

		seqkit fx2tab sequence.faa -l -n -i > length.tsv

        add_column.sh -i length.tsv -o ${network.baseName}_length.tsv -c inflation_${inflation}
		"""
}

process PreparationPfam {

    /*
	* DESCRIPTION
    * -----------
    *   Préparation d'un tableau à deux colonne à partir du tableau généré par hmmsearch
    *
    * INPUT
    * -----
    * 	ficheir (séprateur de colonne : espace), généré par hmmsearch
    *
    * OUPUT
    * -----
    *	Ficheier TSV à 2 colonnes
    *       - colonne 1 : identifiant / nom de la séquence
    *       - colonne 2 : identifiant Pfam
    */

	label 'lagoon'

	input:
		path(search_m8)

	output:
		path("${search_m8.baseName}.tsv"), emit: select_pfam

	script:

		"""
		cut -d "." -f 1 ${search_m8} > ${search_m8.baseName}.pfam

        add_column.sh -i ${search_m8.baseName}.pfam -o ${search_m8.baseName}.tsv -c Pfam
		"""

    stub:
		"""
        touch pfam.tsv
		"""
}