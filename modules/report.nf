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

	label 'lagoon'

    publishDir "${params.outdir}/${params.projectName}_reports", mode: 'copy', pattern: "sequences_stats.html"
    publishDir "${params.outdir}/${params.projectName}_reports", mode: 'copy', pattern: "sequences_stats_files/*"

    input:
        path(quarto)
        path(before)
        path(after)
        path(annotation_network)
        path(length_annotation)

	output:
        path("sequences_stats.html")
        path("sequences_stats_files/*")

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

	label 'lagoon'

    input:
        path(quarto)
        path(network)

	output:
        stdout

	script:
	    """
		quarto render ${quarto} -P network:${network}
        """

    stub:
		"""
        touch report.html
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

	label 'lagoon'

    input:
        tuple path(homogeneity_score), val(inflation), val(database)

	output:
        stdout

	script:
        """
        echo ${homogeneity_score}
        """

    stub:
		"""
        touch report.html
		"""
}