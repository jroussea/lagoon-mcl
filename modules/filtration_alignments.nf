process FiltrationAlignedItself {

    tag "Step 7"

	label 'darkdino'

	//publishDir "${params.outdir}/diamond", mode: 'copy', pattern: 'diamond_ssn*.tsv'
	//publishDir "${params.outdir}/distribution", mode: 'copy', pattern: "*.pdf"

	input:
        path diamond_alignment

	output:
        path "*.itself_tsv", emit: diamond_itself
        //path "*.pdf"

	script:
	"""

    filtration_alignment.py ${diamond_alignment} ${diamond_alignment.baseName}

	"""
}

process FiltrationAlignments {

    tag "Step 7"

	label 'darkdino'

	publishDir "${params.outdir}/diamond", mode: 'copy', pattern: 'diamond_ssn*.tsv'
	publishDir "${params.outdir}/distribution", mode: 'copy', pattern: "*.pdf"

	input:
        path diamond_alignment

	output:
        path "diamond_ssn*.tsv", emit: diamond_ssn
        path "*.pdf"

	script:
	"""

    filtration_alignments.R ${diamond_alignment} ${params.flt_id} ${params.flt_ov} ${params.flt_ev} ${params.filter}

	"""
}