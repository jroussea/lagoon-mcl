process Merge2Dataframe {

    tag "Step 3"

	//label "general_setting"
	label "darkdino"

	//publishDir "${params.outdir}", mode: 'copy', pattern: "*.id_tsv"
	
	input:
        each proteome_name
        path cor_table

	output:
        path "${proteome_name.baseName}.id_tsv", emit: m2d_cor_table

	script:
	"""

    merge_2_dataframe.py ${proteome_name.baseName} ${proteome_name} ${cor_table}

	"""
}

process Attributes {

	tag ""

	label "darkdino"

	publishDir "${params.outdir}", mode: 'copy', pattern: "${m2d_cor_table.baseName}.sequence_id.tsv"

	input:
		each m2d_cor_table
        path annotation

	output:
		path "${m2d_cor_table.baseName}.tab", emit: annot_tab
		path "${m2d_cor_table.baseName}.sequence_id.tsv", emit: annot_seq_id

	script:
	"""
	
	attributes.sh ${m2d_cor_table} ${annotation}/${m2d_cor_table.baseName}.tsv ${m2d_cor_table.baseName}
	
	attributes.py ${m2d_cor_table.baseName}.tab ${annotation}/${m2d_cor_table.baseName}.tsv ${params.pep_colname} ${m2d_cor_table.baseName}
	
	"""
}