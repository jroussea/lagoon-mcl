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

process DiamondBLASTp {

	tag "Step 6"

	label "diamond"

	publishDir "${params.outdir}/diamond", mode: 'copy', pattern: "${params.diamond}"

	input:
		path fasta_rename
        path diamond_db

	output:
        path "${params.diamond}", emit: diamond_alignment

	script:
	"""

    diamond blastp -d ${diamond_db} \
    -q ${fasta_rename} \
    -o ${params.diamond} \
    --${params.sensitivity} \
    -p ${task.cpus} \
    -e ${params.evalue} \
    --matrix ${params.matrix} \
	--outfmt 6 qseqid sseqid pident ppos length mismatch gapopen qstart qend sstart send evalue bitscore

	"""
}