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

    publishDir "${params.outdir}/network/mcl", mode: 'copy', pattern: "seq.dict"
    publishDir "${params.outdir}/network/mcl", mode: 'copy', pattern: "seq.mci"
    publishDir "${params.outdir}", mode: 'copy', pattern: "seq.${filtration}.dict"
    publishDir "${params.outdir}", mode: 'copy', pattern: "seq.${filtration}.mci"


	input:
		tuple path(diamond_ssn), val(filtration)

	output:
        //path "seq.dict", emit: seq_dict
        //path "seq.mci", emit: seq_mci
        
        //tuple path("seq.${filtration}.dict"), val("${filtration}"), emit: tuple_seq_dict
        //tuple path("seq.${filtration}.mci"), val("${filtration}"), emit: tuple_seq_mci
        
        tuple path("seq.${filtration}.dict"), path("seq.${filtration}.mci"), val("${filtration}"), emit: tuple_seq_dict_mci

	script:
	    """
	    sed 1d ${diamond_ssn} -i

        mcxload -abc ${diamond_ssn} -write-tab seq.${filtration}.dict -o seq.${filtration}.mci --stream-mirror --stream-neg-log10 -stream-tf 'ceil(${params.max_weight})'

	    """
}

//mcxload -abc ${diamond_ssn} -write-tab seq.dict -o seq.mci --stream-mirror --stream-neg-log10 -stream-tf 'ceil(${params.max_weight})'


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

    publishDir "${params.outdir}/network/mcl", mode: 'copy', pattern: "${seq_mci_filtration}.I*"

	input:
		each inflation
        //path seq_mci
        //tuple path(seq_mci_filtration), val(filtration)

        tuple path(seq_dict_filtration), path(seq_mci_filtration), val(filtration)

	output:
        //path "out.${seq_mci_filtration}.I*", emit: out_seq_mcl
        //tuple path("out.${seq_mci_filtration}.I*"), val("${filtration}"), emit: tuple_out_seq_mcl

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

    publishDir "${params.outdir}/network/mcl", mode: 'copy', pattern: "dump.${mcl_filtration}"

	input:
        //each out_seq_mcl
        //path seq_dict

        //tuple path(seq_dict_filtration), path(seq_mci_filtration), path(mcl_filtration), val(filtration)
        tuple path(seq_dict_filtration), path(seq_mci_filtration), path(mcl_filtration), val(inflation), val(filtration)

	output:
        //path "dump.out.seq.mci.I*", emit: network_mcl
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

	publishDir "${params.outdir}", mode: 'copy', pattern: "network*"

	input:
        tuple path(seq_dict_filtration), path(seq_mci_filtration), path(mcl_filtration), path(mcl_dump), val(inflation), val(filtration)

	output:
		//path "network_I*", emit: network
        tuple path("network*"), val(inflation), val(filtration), emit: tuple_network

	script:
		"""
        dump_to_tsv.py ${mcl_dump}
        
        dump_to_tsv.R ${mcl_dump}.tsv ${inflation} ${filtration}
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
        path tuple_network
    
    output:
        path "*.tsv"      

    script:
        """
        network_add_attributes.py ${params.columns_attributes} ${network} ${select_annotation} ${network.baseName}
        """
}

process Test {

    /*
	* Processus : 
    *
    * Input:
    * 	- 
    * Output:
    *	- 
    */

	label "mcl"

	input:
		tuple path(diamond_ssn), val(filtration)

	output:
        stdout

	script:
        println("${diamond_ssn} ------ ${filtration}")
	    """
	    """
}
