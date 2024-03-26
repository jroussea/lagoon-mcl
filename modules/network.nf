process NetworkMcxload {

	tag "Step 8.1.1"

	label "mcl"

    publishDir "${params.outdir}/network/mcl", mod: 'copy', pattern: "seq.dict"
    publishDir "${params.outdir}/network/mcl", mod: 'copy', pattern: "seq.mci"

	input:
		path diamond_ssn

	output:
        path "seq.dict", emit: seq_dict
        path "seq.mci", emit: seq_mci

	script:
	"""
    
	sed 1d ${diamond_ssn} -i

    mcxload -abc ${diamond_ssn} -write-tab seq.dict -o seq.mci --stream-mirror --stream-neg-log10 -stream-tf 'ceil(${params.max_weight})'

	"""
}

process NetworkMcl {

	tag "Step 8.1.2"

	label "mcl"

    publishDir "${params.outdir}/network/mcl", mod: 'copy', pattern: "out.seq.mci.I*"

	input:
		each inflation
        path seq_mci

	output:
        stdout
        path "out.seq.mci.I*", emit: out_seq_mcl

	script:
        println("tu n'est pas null mec: $inflation")
        """
        mcl $seq_mci -I $inflation -te ${task.cpus}
        """
}

process NetworkMcxdump {

	tag "Step 8.1.3"

	label "mcl"

    publishDir "${params.outdir}/network/mcl", mod: 'copy', pattern: "dump.${out_seq_mcl.fileName}"

	input:
        each out_seq_mcl
        path seq_dict

	output:
        //stdout
        //path "dump.${out_seq_mcl.fileName}", emit: dump_out_seq_mcl
        path "dump.out.seq.mci.I*"

	script:
        //println("tu n'est pas null mec: $out_seq_mcl")
        //println("dump.${out_seq_mcl.fileName}")
        """
        mcxdump -icl ${out_seq_mcl} -tabr ${seq_dict} -o dump.${out_seq_mcl.fileName}
        """
}

