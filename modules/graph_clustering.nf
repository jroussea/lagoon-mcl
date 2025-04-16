process GRAPH_CLUSTERING {

    /*
	* DESCRIPTION
    * -----------
    * Graph clustering
    * Application of the MCL (Markov CLustering) agorithm to create clusters from a sequence similarity network.
    *
    * INPUT
    * -----
    *   - diamond_ssn: sequence similarity network obtained with diamond BLASTp
    *   - inflation: MCL parameter used to manage clustering granularity
    *
    * OUPUT
    * -----
    *	- dump.out.network.mci.I${inflation}: MCL output file, contains the clusters
    */

    label 'mcl'

    input:
        path(diamond_ssn)
        each inflation

    output:
        tuple path("dump.out.network.mci.I${inflation}"), val("${inflation}"), emit: tuple_mcl_output

    script:
        """
        cut -f 1,5,13 ${diamond_ssn} > ssn_mcl.tsv
        mcxload -abc ssn_mcl.tsv -write-tab network.dict -o network.mci --stream-mirror --stream-neg-log10 -stream-tf 'ceil(${params.max_weight})'
        mcl network.mci -I ${inflation} -te ${task.cpus} --force-connected=y -o out.network.mci.I${inflation}
        mcxdump -icl out.network.mci.I${inflation} -tabr network.dict -o dump.out.network.mci.I${inflation}
        """
}

process MCL_OUTPUT_TO_TSV {

    /*
	* DESCRIPTION
    * -----------
    * Convert MCL output to a TSV file
    *
    * INPUT
    * -----
    * 	- mcl_output: MCL output file, contains the clusters
    *   - inflation: MCL parameter used to manage clustering granularity
    *
    * OUPUT
    * -----
    *	- network_I*.tsv: TSV file containing the network
    */

	label 'lagoon'

	input:
        tuple path(mcl_output), val(inflation)

    output:
        path("network_I*.tsv"), emit: network

	script:
		"""
        mcl_output_to_tsv.py --network ${mcl_output} --inflation ${inflation} --size ${params.cluster_size}
		"""
}

process NETWORK_EDGES {

    /*
	* DESCRIPTION
    * -----------
    * Recover the alignments used to reconstruct the network from the alignment file obtained with Diamond BLASTp.    *
    *
    * INPUT
    * -----
    * 	- network: network file
    *   - diamond_ssn: alignment file
    *
    * OUPUT
    * -----
    *	- edges_*.tsv: contains the alignments needed to rebuild the network
    */

    label 'lagoon'
    
    publishDir "${params.outdir}/lagoon-mcl_output/${network.baseName}/edges", mode: 'copy', pattern: "network_I*_edges.tsv"

    input:
        each path(network)
        path(diamond_ssn)

    output:
        tuple val("${network.baseName}"), path("network_I*_edges.tsv"), emit: tuple_network_edges

    script:
        """
        network_edges.py --network ${network} --alignment ${diamond_ssn} --basename ${network.baseName}
        """
}