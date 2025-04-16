process MMSEQS_CREATE_DB {

    /*
	* DESCRIPTION
    * -----------
    * Construction of the sequence database from user sequences
    *
    * INPUT
    * -----
    * 	- fasta: fasta file
    *
    * OUPUT
    * -----
    *	- queryDB/: sequence database
    */

    label 'mmseqs'

    input:
        path(fasta)

    output:
        path("queryDB/"), emit: path_db
    
    script:
        """
        mkdir queryDB/; cd queryDB/
        mmseqs createdb ../${fasta} queryDB
        """
}

process MMSEQS_SEARCH  {

    /*
	* DESCRIPTION
    * -----------
    * Similarity search in Pfam and AlphaFold clusters databases
    *
    * INPUT
    * -----
    * 	- path_querydb: sequence database
    *   - path_targetdb: MMseqs database from Pfam and AlphaFold clusters
    *   - name_targetdb: Pfam or AlphaFold clusters database name
    *   - run: analysis type: Pfam or AlphaFold clusters 
    *
    * OUPUT
    * -----
    *	- [run]_alignment.m8: pairwise alignment of sequences
    */

    label 'mmseqs'

    input:
        each path(path_querydb)
        path(path_targetdb)
        val(name_targetdb)
        val(run)

    output:
        path("mmseqs2_${run}_alignments.m8"), emit: search_m8

    script:
        """
        mkdir tmp resultDB/
        if [ '${run}' == 'pfamDB' ]; then
            mmseqs search ${path_querydb}/queryDB ${path_targetdb}/${name_targetdb} resultDB/resultDB tmp -k 6 -s 7 --threads ${task.cpus}
        elif [ '${run}' == 'alphafoldDB' ]; then
            mmseqs search ${path_querydb}/queryDB ${path_targetdb}/${name_targetdb} resultDB/resultDB tmp -s 5.7 --threads ${task.cpus}
        
        fi

        mmseqs convertalis ${path_querydb}/queryDB ${path_targetdb}/${name_targetdb} resultDB/resultDB mmseqs2_${run}_alignments.m8 --threads ${task.cpus} --format-output query,target,fident,alnlen,mismatch,gapopen,qstart,qend,qlen,tstart,tend,tlen,evalue,bits
        """
}