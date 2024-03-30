process JsonGeneralInformations {

    /*
	* Processus : 
    *
    * Input:
    * 	- 
    * Output:
    *	- 
    */

	label "darkdino"

	publishDir "${params.tmpFile}/json", mode: 'copy', pattern: "*.json"

	input:
        path m2d_cor_table

	output:
		path "${m2d_cor_table.baseName}.json"

	script:

		"""

		json_general_informations.py ${m2d_cor_table} ${m2d_cor_table.baseName}

		"""
}

process JsonSequenceInformation {

	/*
	* Processus : 
    *
    * Input:
    * 	- 
    * Output:
    *	- 
    */

	label "darkdino"

	publishDir "${params.outdir}/json/sequence_information", mode: 'copy', pattern: "${annot_tab.baseName}.json"

	input:
		path json_file
		path annotation
		each annot_tab

	output:
		path "${annot_tab.baseName}.json", emit: json_information
	
	script:
		"""
		json_annotations.py ${annot_tab.baseName} ${annotation}/${annot_tab.baseName}.tsv \
							${json_file}/${annot_tab.baseName}.json ${annot_tab} \
							${params.pep_colname} ${params.columns} ${params.columns_infos}
		"""
}