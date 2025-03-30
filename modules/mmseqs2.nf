process MMseqsCreateDB {

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

    label 'mmseqs'

    input:
        val(database)
        path(fasta_sequences)

    output:
        path("${database}/"), emit: path_db
        val("${database}"), emit: name_db
    
    script:
        """
        mkdir ${database}; cd ${database}
        mmseqs createdb ../${fasta_sequences} ${database}
        """
}

process MMseqsSearch  {

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

    label 'mmseqs'

    input:
        path(path_queryDB)
        val(name_queryDB)
        path(path_targetdb)
        val(name_targetdb)
        val(run)

    output:
        tuple path("${name_targetdb}_alignment.m8"), val("${name_targetdb}"), emit: search_m8

    script:
        """
        mkdir tmp resultDB/
        if [ '${run}' == 'run_pfam' ]; then
            mmseqs search ${path_queryDB}/${name_queryDB} ${path_targetdb}/${name_targetdb} resultDB/resultDB tmp -k 6 -s 7 --threads ${task.cpus}
        elif [ '${run}' == 'run_alphafold' ]; then
            mmseqs search ${path_queryDB}/${name_queryDB} ${path_targetdb}/${name_targetdb} resultDB/resultDB tmp -k 5 -s 5.7 --threads ${task.cpus}
        
        fi

        mmseqs convertalis ${path_queryDB}/${name_queryDB} ${path_targetdb}/${name_targetdb} resultDB/resultDB ${name_targetdb}_alignment.m8 --threads ${task.cpus} --format-output query,target,fident,alnlen,mismatch,gapopen,qstart,qend,qlen,tstart,tend,tlen,evalue,bits
        """
    
}

process PfamProcessing {

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
        tuple path(search_m8), val(name_targetdb)
        path(fasta)

    output:
        path("${name_targetdb}.tsv"), emit: file_format

    script:
        """
        pfam_processing.py --pfam_scan ${search_m8} --fasta ${fasta} --evalue 0.00001 --database ${name_targetdb}
        """
}