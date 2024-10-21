process SequenceHtml {
    
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

   	publishDir "$baseDir/results/html", mode: 'copy', pattern: "sequences_stats.html"
    publishDir "$baseDir/results/html", mode: 'copy', pattern: "sequences_stats_files/*"


	label 'lagoon'

    input:
        path(quarto)
        path(before)
        path(after)
        path(annotation)
        path(annotation_network)

	output:
	    path("sequences_stats.html")
        path("sequences_stats_files/*")

	script:
	"""
        cat ${annotation} > annotation
        cat ${annotation_network} > annotation_network

        echo ${annotation_network}

		quarto render ${quarto} -P before:${before} -P after:${after} -P annotation:annotation -P annotation_network:annotation_network
    """
}


//        cat ${class} ${architecture} ${topology} ${superfamily} > annotation.tsv
