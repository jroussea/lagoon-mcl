process CheckFastaFormat {

    /*
	* DESCRIPTION
    * -----------
    *
    * INPUT
    * -----
    * 	- 
    * OUPUT
    * -----
    *	- 
    */

    label 'lagoon'

    input:
        path(sequences)
    
    output:
		path("${sequences}"), emit: sequences_verif

    script:
        """
        check_input_file.py -i ${sequences} -t fasta -n fasta
        """
}

process CheckCsvFormat {

    /*
	* DESCRIPTION
    * -----------
    *
    * INPUT
    * -----
    * 	- 
    * OUPUT
    * -----
    *	- 
    */

    label 'lagoon'
    
    input:
        path(csv_file)

    output:
        path("${csv_file}"), emit: csv_verif

    script:
        """
        check_input_file.py -i ${csv_file} -t csv -d "," -n annotation
        """
}

process CheckLabelFormat {

    /*
	* DESCRIPTION
    * -----------
    *
    * INPUT
    * -----
    * 	- 
    * OUPUT
    * -----
    *	- 
    */

    label 'lagoon'

    input:
        tuple val(annotation), path(file)

    output:
        tuple val("${annotation}"), path("${file}"), emit: label_annotation

    script:
        """
        check_input_file.py -i ${file} -t label -n ${annotation}
        """
}