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
//    mcl $seq_mci -I $inflation
//-te ${task.cpus}
