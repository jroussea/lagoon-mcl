process NetworkMcl {

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

    label 'mcl'

    input:
        path(diamond_ssn)
        each inflation

    output:
        tuple path("dump.out.network.mci.I${inflation}"), val("${inflation}"), emit: tuple_dump

    script:
        """
        cut -f 1,5,13 ${diamond_ssn} > ssn_mcl.tsv
        mcxload -abc ssn_mcl.tsv -write-tab network.dict -o network.mci --stream-mirror --stream-neg-log10 -stream-tf 'ceil(${params.max_weight})'
        mcl network.mci -I ${inflation} -te ${task.cpus} --force-connected=y -o out.network.mci.I${inflation}
        mcxdump -icl out.network.mci.I${inflation} -tabr network.dict -o dump.out.network.mci.I${inflation}
        """

}

process NetworkMclToTsv {

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
        tuple path(network_dump), val(inflation)

    output:
        path("network_I*.tsv"), emit: network

	script:
		"""
        dump_to_tsv.py --network ${network_dump} --inflation ${inflation} --size ${params.cluster_size}
		"""

    stub:
		"""
		touch network_I${inflation}.tsv
		"""
}

process NetworkEdge {

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
    
    publishDir "${params.outdir}/lagoon-mcl_output/${network.baseName}/edges", mode: 'copy', pattern: "edges_*.tsv"

    input:
        path(network)
        each path(diamond_ssn)

    output:
        tuple val("${network.baseName}"), path("edges_*.tsv"), emit: tuple_edge

    script:
        """
        network_edges.py --network ${network} --alignment ${diamond_ssn} --basename ${network.baseName}
        """
}