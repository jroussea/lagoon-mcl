process DiamondDB {

	tag "Step 5"

	label "diamond"

	publishDir "${params.outdir}/diamond", mode: 'copy', pattern: "${params.diamond_db}.dmnd"

	input:
		path fasta_rename

	output:
        path "${params.diamond_db}.dmnd", emit: diamond_db

	script:
	"""

    diamond makedb --in ${fasta_rename} -d ${params.diamond_db} -p ${task.cpus}

	"""
}