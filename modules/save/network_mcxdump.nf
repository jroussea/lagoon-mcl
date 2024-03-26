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
        println("tu n'est pas null mec: $out_seq_mcl")
        println("dump.${out_seq_mcl.fileName}")
        """
        mcxdump -icl ${out_seq_mcl} -tabr ${seq_dict} -o dump.${out_seq_mcl.fileName}
        """
}
//        mcxdump -icl ${out_seq_mcl} -tabr ${seq_dict} -o dump_${out_seq_mcl}
