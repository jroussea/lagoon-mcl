process GeneralReport {
    
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

    publishDir "${params.outdir}/lagoon-mcl_reports/", mode: 'copy', pattern: "sequences_and_clusters/*"

    input:
        path(quarto_seqs_clst)
        path(seq_length)
        path(seq_length_network)
        path(all_network)

	output:
        path("sequences_and_clusters/*")

	script:
        """
        quarto render ${quarto_seqs_clst} -P length:${seq_length} -P length_network:${seq_length_network} -P network:${all_network} --output-dir sequences_and_clusters
        """

    stub:
		"""
        mkdir sequences_and_clusters/report.html
		"""
}

process HomScoreReport {

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

    publishDir "${params.outdir}/lagoon-mcl_output/homogeneity_score", mode: 'copy', pattern: "homogeneity_score_${annotation}.tsv"

    input:
        tuple val(annotation), path(homogeneity_score)

    output:
        path("homogeneity_score_${annotation}.tsv")

    script:
        """
        cat ${homogeneity_score} > homogeneity_score_${annotation}.tsv
        """
}