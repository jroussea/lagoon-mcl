process NetworkMcxload {

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

	output:
        
        tuple path("network.dict"), path("network.mci"), emit: tuple_seq_dict_mci
        path("network.matrice"), emit: network_matrice

	script:
        """
        sed 1d ${diamond_ssn} > diamond_ssn.tmp
        mcxload -abc diamond_ssn.tmp -write-tab network.dict -o network.mci --stream-mirror --stream-neg-log10 -stream-tf 'ceil(${params.max_weight})'
        mcxdump -imx network.mci -tab network.dict -o network.matrice
        """

	stub:
		"""
        touch network.dict
		touch network.matrice
        touch network.mci
		"""
}

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
		each inflation
        tuple path(network_dict), path(network_mci)

	output:
        tuple path("${network_dict}"), path("${network_mci}"), path("out.network.mci.I*"), val("${inflation}"), emit: tuple_mcl

	script:
        
        """
        mcl $network_mci -I $inflation -te ${task.cpus} 
        """
        //-write-graph network_mcl_I${inflation}.graph --analyze=y
	stub:
		"""
        touch ${network_dict}
		touch ${network_mci}
        touch out.network.mci.I2
		"""
}

process NetworkMcxdump {

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
        tuple path(network_dict), path(network_mci), path(network_mcl), val(inflation)

	output:
        tuple path("${network_dict}"), path("${network_mci}"), path("${network_mcl}"), path("dump.${network_mcl}"), val("${inflation}"), emit: tuple_dump

	script:
        """
        mcxdump -icl ${network_mcl} -tabr ${network_dict} -o dump.${network_mcl}
        """

	stub:
		"""
        touch ${network_dict}
        touch ${network_mci}
        touch ${network_mcl}
        touch dump.${network_mcl}
		"""
}

process FiltrationCluster {

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
        tuple path(network_dict), path(network_mci), path(network_mcl), path(network_dump), val(inflation)
    
    output:
        tuple path("conserved_cluster_*.txt"), val("${inflation}"), emit: tuple_filtration
        
    script:
        """
        cluster_filtration.py --network ${network_dump} --inflation ${inflation} --min ${params.cluster_size}
        """

	stub:
		"""
        touch conserved_cluster_2.txt
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

	publishDir "${params.outdir}/network/", mode: 'copy', pattern: "network_I*.tsv"

	input:
        tuple path(network), val(inflation)

	output:
        tuple path("network_I*.tsv"), val("${inflation}"), emit: tuple_network
        path("network_I*.tsv"), emit: network

	script:
		"""
        network_dump_to_tsv.py --network ${network} --inflation ${inflation}
		"""

    stub:
		"""
        touch network_I2.tsv
		"""
}