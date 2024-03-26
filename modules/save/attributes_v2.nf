process AttributesV2 {

	tag "Step 4"

	label "general_setting"

	publishDir "${params.outdir}/an_file_id", mode: 'copy', pattern: "${m2d_cor_table.baseName}.sequence_id.tsv"

	input:
		each m2d_cor_table
        path annotation

	output:
		path "${m2d_cor_table.baseName}.sequence_id.tsv", emit: annot_seq_id

	script:
	"""

    attributes_v2.py ${m2d_cor_table} ${annotation}/${m2d_cor_table.baseName}.tsv ${m2d_cor_table.baseName} ${params.pep_colname}
    
	"""
}
