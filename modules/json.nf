process JsonGeneralInformations {

	tag "Step 2"

	label "darkdino"

	//publishDir "${params.outdir}/diamond", mode: 'copy', pattern: 'reference.dmnd'
	publishDir "${params.tmpFile}/json", mode: 'copy', pattern: "*.json"

	input:
        path m2d_cor_table
		//path annotation
    	//path cor_table

	output:
		//stdout
        //path "${proteome.baseName}.name", emit: proteome_name
    	//path "reference.dmnd", emit: diamond_reference
		path "${m2d_cor_table.baseName}.json"

	script:
		//println("${name} --- ${correspondance_table} --- ${annotation_table}")
		"""
		json_general_informations.py ${m2d_cor_table} ${m2d_cor_table.baseName}
		"""
}
//tuple val("${proteome_name.baseName}"), path("${proteome_name.baseName}.id_tsv"), emit: tuple_new_cor_table

// 1 - basenamee
// 2 - correspondance tble (id_tsv)
// 3 - table d'anotation avec ID
// 4 - string si colonne link
//        json_sequence_information.py 

process JsonSequenceInformation {

	tag ""

	label "darkdino"

	//publishDir "${params.outdir}/json/sequence_information", mode: 'copy', pattern: "${annot_tab.baseName}.json"

	input:
		path json_file
		path annotation
		each annot_tab

		//tuple path("${json}"), path("${cor_table}")// fichier tsv de base
		//path annotation // fichier json
		//path // table de correspondance

	output:
		stdout
		//path "${annot_tab.baseName}.json", emit: json_information
	
	script:

		//println("${json_file}/${annot_tab.baseName}.json")
		"""
		
		json_annotations.py ${annot_tab.baseName} ${annotation}/${annot_tab.baseName}.tsv \
							${json_file}/${annot_tab.baseName}.json ${annot_tab} \
							${params.pep_colname} ${params.columns} ${params.columns_infos}
		"""
}
//		json_annotations.py ${annot_tab.baseName} ${annotation}/${annot_tab.baseName}.tsv ${json_file}/${annot_tab.baseName}.json ${annot_tab} ${params.pep_colname} ${params.columns} ${params.columns_infos}

//		json_annotations.py ${annot_tab.baseName} ${annotation}/${annot_tab.baseName}* \
//							${json_file}/${annot_tab.baseName}.json ${annot_tab} \
//							${params.pep_colname} ${params.columns} ${params.columns_infos}
//		json_annotations.py ${x} ${x} ${x} ${params.pep_colname} ${params.columns} ${params.columns_infos}

//${params.pep_colname}
//${params.columns}
//${params.columns_infos}
