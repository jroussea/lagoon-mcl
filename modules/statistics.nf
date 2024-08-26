process HomogeneityScore {
    
    /*
	* Processus : 
    *
    * Input:
    * 	- 
    * Output:
    *	- 
    */

    tag ''

	publishDir "${params.outdir}/homogeneity_score/inflation_${inflation}/tsv", mode: 'copy', pattern: "*.tsv"
    publishDir "${params.outdir}/homogeneity_score/inflation_${inflation}/labels", mode: 'copy', pattern: "*all*.txt"
    publishDir "${params.outdir}/homogeneity_score/inflation_${inflation}/labels", mode: 'copy', pattern: "*annotated*.txt"

    input:
        each label_network
        tuple path(network_tsv), val(inflation)
    
    output:
        tuple path("*.tsv"), val("${inflation}"), val("${label_network.baseName}"), emit: tuple_hom_score

    script:
        """
        network_homogeneity_score.py ${network_tsv} ${label_network} ${params.pep_colname} ${inflation} ${label_network.baseName}
        """
}

process PlotHomogeneityScore {

    tag ''

    publishDir "${params.outdir}/homogeneity_score/inflation_${inflation}/pdf", mode: 'copy', pattern: "*.pdf"

    input:
        tuple path(homogeneity_score), val(inflation), val(label_network)

    output:
        path "*.pdf"

    script:
        """
        distribution_homogeneity_score.R ${homogeneity_score} ${inflation} ${label_network}
        """

}

process PlotClusterSize {

    tag ''

    publishDir "${params.outdir}/network_statistics/cluster_size/tsv", mode: 'copy', pattern: "*.tsv"
    publishDir "${params.outdir}/network_statistics/cluster_size/", mode: 'copy', pattern: "*.pdf"
    //publishDir "$baseDir/lagoon-mcl-shiny/data/cluster_size/tsv", mode: 'copy', pattern: "*.tsv"

    input:
        tuple path(network_tsv), val(inflation)

    output:
        path("*.tsv"), emit: cluster_size
        path("*.pdf")

    script:
        """
        cluster_size.R ${network_tsv} ${inflation}
        """
}
