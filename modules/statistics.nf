process HomogeneityScore {
    
    /*
	* Processus : 
    *
    * Input:
    * 	- 
    * Output:
    *	- 
    */

    label 'lagoon'

	publishDir "${params.outdir}/lagoon-mcl_output/homogeneity_score", mode: 'copy', pattern: "homogeneity_score_${label_network.baseName}_I${inflation}.tsv"
    publishDir "${params.outdir}/lagoon-mcl_output/homogeneity_score/labels", mode: 'copy', pattern: "*.txt"

    input:
        each path(label_network)
        tuple path(network_tsv), val(inflation)
    
    output:
        tuple val("${label_network.baseName}"), path("homogeneity_score_${label_network.baseName}_I${inflation}.tsv"), emit: tuple_hom_score
        path("${label_network.baseName}.txt")

    script:
        """
        echo ${label_network}
        cut -f 1,2 ${network_tsv}  > network
        cut -f 1,2 ${label_network} > label

        network_homogeneity_score.py --network network --label label --inflation ${inflation} --basename ${label_network.baseName}
        """

    stub:
		"""
        touch ${label_network.baseName}.tsv
        touch ${label_network.baseName}.txt
		"""
}