process JsonSequenceInformation {

	tag "Step 2"

	//label "general_setting"

	//publishDir "${params.outdir}/diamond", mode: 'copy', pattern: 'reference.dmnd'

	input:
        tuple val(name), path(correspondance_table), path(annotation_table)
	//	path annotation
    //    path cor_table

	output:
		stdout
        //path "${proteome.baseName}.name", emit: proteome_name
    	//path "reference.dmnd", emit: diamond_reference

	script:
		println("${name} --- ${correspondance_table} --- ${annotation_table}")
		"""
		json_sequence_information.py ${name} ${correspondance_table} ${annotation_table} ${params.columns}
		"""
}

// 1 - basenamee
// 2 - correspondance tble (id_tsv)
// 3 - table d'anotation avec ID
// 4 - string si colonne link
//        json_sequence_information.py 
