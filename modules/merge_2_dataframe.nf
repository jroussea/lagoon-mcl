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