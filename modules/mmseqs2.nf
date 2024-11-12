process DownloadPfam {
    
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

	output:
	    path("pfam/"), emit: pfamDB

	script:
	"""
        mkdir pfam ; cd pfam
        mmseqs databases Pfam-A.full pfam tmp
    """
}

process MMseqsSearch {
    
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
        each path(query_fasta)
        path(targetDB)
        val(database)

	output:
		//stdout
        path("${query_fasta.baseName}.m8"), emit: search_m8

	script:
	"""
        mkdir queryDB ; cd queryDB
		mmseqs createdb ../${query_fasta} queryDB
        cd ..
        mkdir tmp resultDB/
        mmseqs search queryDB/queryDB ${targetDB}/${database} resultDB/resultDB tmp --max-accept 10 -s 4.0 --threads ${task.cpus}
        mmseqs convertalis queryDB/queryDB ${targetDB}/${database} resultDB/resultDB ${query_fasta.baseName}.m8 --threads ${task.cpus} --format-output query,target,fident,alnlen,mismatch,gapopen,qstart,qend,qlen,tstart,tend,tlen,evalue,bits
	"""
}
