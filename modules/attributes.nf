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

	//publishDir "${params.outdir}", mode: 'copy', pattern: "${m2d_cor_table.baseName}.sequence_id.tsv"

	input:
		each m2d_cor_table
        path annotation

	output:
		path "${m2d_cor_table.baseName}.tab", emit: annot_tab
		path "${m2d_cor_table.baseName}.sequence_id_tsv", emit: annot_seq_id

	script:
	"""
	
	attributes.sh ${m2d_cor_table} ${annotation}/${m2d_cor_table.baseName}.tsv ${m2d_cor_table.baseName}
	
	attributes.py ${m2d_cor_table.baseName}.tab ${annotation}/${m2d_cor_table.baseName}.tsv ${params.pep_colname} ${m2d_cor_table.baseName}
	
	"""
}

process SelectInfosNodes {

	//publishDir "${params.outdir}", mode: 'copy', pattern: "${annot_seq_id.baseName}.tmp"

	input:
		path annot_seq_id

	output:
		path "${annot_seq_id.baseName}.tmp", emit: select_annotation

		//stdout

	script:
		//println("${nodes_infos} ---- ${annot_seq_id}")
		//println("${nodes_infos}")
	    //String test = "${nodes_infos}".replace("|", ",");
		//List<String> name = Arrays.asList(test.split(","))
		//println(name.get(0))
		"""

		select_infos_nodes.py ${annot_seq_id} "${params.test}" ${annot_seq_id.baseName}

		"""
}
//		select_infos_nodes.py ${annot_seq_id} ${params.test} ${annot_seq_id.baseName}
