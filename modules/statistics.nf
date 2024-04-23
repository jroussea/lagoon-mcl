process HomogeneityScore {
    
    /*
	* Processus : 
    *
    * Input:
    * 	- 
    * Output:
    *	- 
    */

    label 'darkdino'

	publishDir "${params.outdir}/homogeneity_score/inflation_${inflation}/tsv_all", mode: 'copy', pattern: "*all*.tsv"
	publishDir "${params.outdir}/homogeneity_score/inflation_${inflation}/tsv_annotated", mode: 'copy', pattern: "*annotated*.tsv"

    input:
        each label_network
        tuple path(network_tsv), val(inflation)
    
    output:
        tuple path("*all*.tsv"), val("${inflation}"), val("${label_network.baseName}"), val("all"), emit: tuple_hom_score_all
        tuple path("*annotated*.tsv"), val("${inflation}"), val("${label_network.baseName}"), val("annotated"), emit: tuple_hom_score_annotated

    script:
        """
        network_homogeneity_score.py ${network_tsv} ${label_network} ${params.pep_colname} ${inflation} ${label_network.baseName}
        """
}

process PlotHomogeneityScore {

    label 'darkdino'

    publishDir "${params.outdir}/homogeneity_score/inflation_${inflation}/pdf_${characteristic}", mode: 'copy', pattern: "*${characteristic}*.pdf"

    input:
        tuple path(homogeneity_score), val(inflation), val(label_network), val(characteristic)

    output:
        path "*${characteristic}*.pdf"

    script:
        """
        distribution_homogeneity_score.R ${homogeneity_score} ${inflation} ${label_network} ${characteristic}
        """

}

process PlotClusterSize {

    label 'darkdino'

    publishDir "${params.outdir}/network_statistics/cluster_size/tsv", mode: 'copy', pattern: "*.tsv"
    publishDir "${params.outdir}/network_statistics/cluster_size/", mode: 'copy', pattern: "*.pdf"

    input:
        tuple path(network_tsv), val(inflation)

    output:

        path("*.tsv")
        path("*.pdf")

    script:
        """
        cluster_size.R ${network_tsv} ${inflation}
        """
}