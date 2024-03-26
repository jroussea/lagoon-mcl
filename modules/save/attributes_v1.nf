process AttributesV1 {

	tag "Step 4"

	label "general_setting"

	publishDir "${params.outdir}/an_file_id", mode: 'copy', pattern: "${m2d_cor_table.baseName}.sequence_id.tsv"

	input:
		each m2d_cor_table
        path annotation

	output:
		path "${m2d_cor_table.baseName}.sequence_id.tsv", emit: annot_seq_id
		tuple val("${m2d_cor_table.baseName}"), path("${m2d_cor_table.baseName}.sequence_id.tsv"), emit: tuple_annot_seq_id

	script:
	"""
	date
	attributes_v1.sh ${m2d_cor_table} ${annotation}/${m2d_cor_table.baseName}.tsv ${m2d_cor_table.baseName}
	date	
	attributes_v1.py ${m2d_cor_table.baseName}.tab ${annotation}/${m2d_cor_table.baseName}.tsv ${params.pep_colname} ${m2d_cor_table.baseName}
	date
	"""
}
