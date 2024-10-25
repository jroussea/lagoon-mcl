process SequenceHtml {
    
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

	tag ''

   	publishDir "$baseDir/results/html", mode: 'copy', pattern: "sequences_stats.html"
    publishDir "$baseDir/results/html", mode: 'copy', pattern: "sequences_stats_files/*"


	label 'lagoon'

    input:
        path(quarto)
        path(before)
        path(after)
        path(annotation_network)
        path(length_annotation)

	output:
        stdout

	script:
	"""
    cat ${annotation_network} > annotation_network
    cat ${length_annotation} > length_annotation

    quarto render ${quarto} -P before:${before} -P after:${after} -P annotation_network:annotation_network -P length_annotation:length_annotation
    """
}

process ClusterHtml {
    
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
	tag ''

	label 'lagoon'

    input:
        path(quarto)
        path(network)

	output:
        stdout

	script:
	"""
        echo ${network}

        sed -s -i '1d' ${network}

        cat ${network} > network.tsv

		quarto render ${quarto} -P network:network.tsv
    """
}

process HomScoreHtml {
    
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

	tag ''

	label 'lagoon'

    input:
        tuple path(homogeneity_score), val(inflation), val(database)

	output:
        stdout

	script:
	"""
    echo ${homogeneity_score}
    """
}