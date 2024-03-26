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
