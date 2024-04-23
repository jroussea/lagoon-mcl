process NetworkMcxload {

    /*
	* Processus : 
    *
    * Input:
    * 	- 
    * Output:
    *	- 
    */

	label "mcl"

    publishDir "${params.outdir}/network/mcl/mcx_load", mode: 'copy', pattern: "network.dict"
    publishDir "${params.outdir}/network/mcl/mcx_load", mode: 'copy', pattern: "network.mci"


	input:
		path diamond_ssn

	output:
        
        tuple path("network.dict"), path("network.mci"), emit: tuple_seq_dict_mci

	script:
	    """
	    sed 1d ${diamond_ssn} > diamond_ssn.tmp

        mcxload -abc diamond_ssn.tmp -write-tab network.dict -o network.mci --stream-mirror --stream-neg-log10 -stream-tf 'ceil(${params.max_weight})'

	    """
}

process NetworkMcl {

    /*
	* Processus : 
    *
    * Input:
    * 	- 
    * Output:
    *	- 
    */

	label "mcl"

    publishDir "${params.outdir}/network/mcl/mcl", mode: 'copy', pattern: "out.network.mci.I*"
    publishDir "${params.outdir}/network/mcl/mcl", mode: 'copy', pattern: "network_mcl_I${inflation}.graph"

	input:
		each inflation
        tuple path(network_dict), path(network_mci)

	output:
        tuple path("${network_dict}"), path("${network_mci}"), path("out.network.mci.I*"), val("${inflation}"), emit: tuple_mcl

	script:
        
        """
        mcl $network_mci -I $inflation -te ${task.cpus} -write-graph network_mcl_I${inflation}.graph --analyze=y
        """
}

process NetworkMcxdump {

    /*
	* Processus : 
    *
    * Input:
    * 	- 
    * Output:
    *	- 
    */

	label "mcl"

    publishDir "${params.outdir}/network/mcl/mcx_dump", mode: 'copy', pattern: "dump.${network_mcl}"

	input:
        tuple path(network_dict), path(network_mci), path(network_mcl), val(inflation)

	output:
        tuple path("${network_dict}"), path("${network_mci}"), path("${network_mcl}"), path("dump.${network_mcl}"), val("${inflation}"), emit: tuple_dump

	script:
        """
        mcxdump -icl ${network_mcl} -tabr ${network_dict} -o dump.${network_mcl}
        """
}

process NetworkMclToTsv {

    /*
	* Processus : 
    *
    * Input:
    * 	- 
    * Output:
    *	- 
    */

	label 'darkdino'

	publishDir "${params.outdir}/network/mcl/tsv", mode: 'copy', pattern: "network_I*.tsv"

	input:
        tuple path(network_dict), path(network_mci), path(network_mcl), path(network_dump), val(inflation)

	output:
        tuple path("network_I*.tsv"), val("${inflation}"), emit: tuple_network

	script:
		"""
        network_dump_to_tsv.sh ${network_dump} ${inflation} ${params.pep_colname}
		"""
}