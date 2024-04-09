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

    publishDir "${params.outdir}/network/mcl/mcx_load", mode: 'copy', pattern: "seq.${filtration}.dict"
    publishDir "${params.outdir}/network/mcl/mcx_load", mode: 'copy', pattern: "seq.${filtration}.mci"


	input:
		tuple path(diamond_ssn), val(filtration)

	output:
        
        tuple path("seq.${filtration}.dict"), path("seq.${filtration}.mci"), val("${filtration}"), emit: tuple_seq_dict_mci

	script:
	    """
	    sed 1d ${diamond_ssn} -i

        mcxload -abc ${diamond_ssn} -write-tab seq.${filtration}.dict -o seq.${filtration}.mci --stream-mirror --stream-neg-log10 -stream-tf 'ceil(${params.max_weight})'

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

    publishDir "${params.outdir}/network/mcl/mcl", mode: 'copy', pattern: "out.${seq_mci_filtration}.I*"

	input:
		each inflation
        tuple path(seq_dict_filtration), path(seq_mci_filtration), val(filtration)

	output:
        tuple path("${seq_dict_filtration}"), path("${seq_mci_filtration}"), path("out.${seq_mci_filtration}.I*"), val("${inflation}"), val("${filtration}"), emit: tuple_mcl

	script:
        
        """
        mcl $seq_mci_filtration -I $inflation -te ${task.cpus}
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

    publishDir "${params.outdir}/network/mcl/mcx_dump", mode: 'copy', pattern: "dump.${mcl_filtration}"

	input:
        tuple path(seq_dict_filtration), path(seq_mci_filtration), path(mcl_filtration), val(inflation), val(filtration)

	output:
        tuple path("${seq_dict_filtration}"), path("${seq_mci_filtration}"), path("${mcl_filtration}"), path("dump.${mcl_filtration}"), val("${inflation}"), val("${filtration}"), emit: tuple_dump

	script:
        """
        mcxdump -icl ${mcl_filtration} -tabr ${seq_dict_filtration} -o dump.${mcl_filtration}
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

	publishDir "${params.outdir}/network/mcl/tsv", mode: 'copy', pattern: "network*"

	input:
        tuple path(seq_dict_filtration), path(seq_mci_filtration), path(mcl_filtration), path(mcl_dump), val(inflation), val(filtration)

	output:
        tuple path("network*"), val("${inflation}"), val("${filtration}"), emit: tuple_network

	script:
		"""
        network_dump_to_tsv.py ${mcl_dump}
        
        network_dump_to_tsv.R ${mcl_dump}.tsv ${inflation} ${filtration}
		"""
}

process NetworkAddAttributes {
    
    /*
	* Processus : 
    *
    * Input:
    * 	- 
    * Output:
    *	- 
    */

    label 'darkdino'

	publishDir "${params.outdir}/homogeneity_score", mode: 'copy', pattern: "*.tsv"

    input:
        path select_annotation
        tuple path(network), val(inflation), val(filtration)
    
    output:
        tuple path("*.tsv"), val("${inflation}"), val("${filtration}"), emit: tuple_hom_score

    script:
        """
        network_homogeneity_score.py ${params.columns_attributes} ${network} ${select_annotation} ${inflation} ${filtration}
        """
}

process HomogeneityScorePlot {

    label 'darkdino'

    publishDir "${params.outdir}/homogeneity_score", mode: 'copy', pattern: "*.pdf"

    input:
        tuple path(hom_score), val(inflation), val(filtration)
    
    output:
        path "*.pdf"

    script:
        """
        distribution_homogeneity_score.R ${hom_score} ${inflation} ${filtration}
        """

}