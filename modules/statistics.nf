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

    label 'lagoon'

	publishDir "${params.outdir}/homogeneity_score/inflation_${inflation}/tsv", mode: 'copy', pattern: "*.tsv"
    publishDir "${params.outdir}/homogeneity_score/inflation_${inflation}/labels", mode: 'copy', pattern: "*.txt"

    input:
        each path(label_network)
        tuple path(network_tsv), val(inflation)
    
    output:
        tuple path("*.tsv"), val("${inflation}"), val("${label_network.baseName}"), emit: tuple_hom_score
        path "*.txt"

    script:
        """
        echo ${label_network}
        cut -f 1,2 ${network_tsv}  > network
        cut -f 1,2 ${label_network} > label

        network_homogeneity_score.py --network network --label label --inflation ${inflation} --basename ${label_network.baseName}
        """
}