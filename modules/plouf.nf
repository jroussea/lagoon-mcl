process Plouf {

	tag "Step 4"

	label "general_setting"

	//publishDir "${params.outdir}/an_file_id", mode: 'copy', pattern: "${m2d_cor_table.baseName}.sequence_id.tsv"

	input:
		path m2d_cor_table
        //path annotation

	output:
		stdout
		//path "${m2d_cor_table.baseName}.sequence_id.tsv", emit: annot_seq_id
		//tuple val("${m2d_cor_table.baseName}"), path("${m2d_cor_table.baseName}.sequence_id.tsv"), emit: tuple_annot_seq_id

	script:
		//println("${m2d_cor_table} \n ${m2d_cor_table.baseName} \n ${annotation}/${m2d_cor_table.baseName}.tsv")
		"""
		attributes_v1.sh ${m2d_cor_table} ${params.annotation}/${m2d_cor_table.baseName}.tsv ${m2d_cor_table.baseName}
		attributes_v1_merge.py ${m2d_cor_table.baseName}.patterns ${m2d_cor_table.baseName}.sequence_id ${m2d_cor_table.baseName}
		attributes_v1.py ${m2d_cor_table.baseName}.tab ${params.annotation}/${m2d_cor_table.baseName}.tsv ${params.pep_colname} ${m2d_cor_table.baseName}
		"""
}

//	attributes_v1_merge.py ${m2d_cor_table.baseName}.patterns ${m2d_cor_table.baseName}.sequence_id ${m2d_cor_table.baseName}
	
//	attributes_v1.py ${m2d_cor_table.baseName}.tab ${annotation}/${m2d_cor_table.baseName}.tsv ${params.pep_colname} ${m2d_cor_table.baseName}