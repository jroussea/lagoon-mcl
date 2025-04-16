process CHECKS_FASTA {

    /*
	* DESCRIPTION
    * -----------
    * Check that the files respect the FASTA format and that they contain protein sequences.
    *
    * INPUT
    * -----
    * 	- User-supplied file format
    *
    * OUPUT
    * -----
    *	- Same files as input
    */

    label 'lagoon'

    input:
        path(sequences)
    
    output:
		path("${sequences}"), emit: sequences_checking

    script:
        """
        checks_inputs.py -i ${sequences} -t fasta -n fasta
        """
}

process CHECK_CSV {

    /*
	* DESCRIPTION
    * -----------
    * Check that the files respect the CSV format
    * 
    * INPUT
    * -----
    * 	- User-supplied file format
    *
    * OUPUT
    * -----
    *	- Same files as input
    */

    label 'lagoon'
    
    input:
        path(csv_file)

    output:
        path("${csv_file}"), emit: csv_checking

    script:
        """
        checks_inputs.py -i ${csv_file} -t csv -d "," -n annotation
        """
}

process CHECKS_TSV {

    /*
	* DESCRIPTION
    * -----------
    * Check that the files respect the TSV format
    *
    * INPUT
    * -----
    * 	- User-supplied file format
    *
    * OUPUT
    * -----
    *	- Same files as input
    */

    label 'lagoon'

    input:
        tuple val(annotation), path(file)

    output:
        tuple val("${annotation}"), path("${file}"), emit: tsv_checking

    script:
        """
        checks_inputs.py -i ${file} -t label -n ${annotation}
        """
}
