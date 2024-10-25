process HMMsearch {
    
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

	tag ''

	label 'hmmer'

	input:
        each path(proteome)
		path(hmms)
		val(Z)
		val(domE)
		val(incdomE)

	output:
        path("${proteome.baseName}.hmmsearch"), emit: hmmsearch
		path("${proteome.baseName}.tsv"), emit: hmmsearch_tsv

	script:
	"""
    	hmmsearch \
			-Z ${Z} \
			--domE ${domE} \
			--incdomE ${incdomE} \
			--cpu ${task.cpus} \
			--tblout ${proteome.baseName}.out \
			-o ${proteome.baseName}.hmmsearch ${hmms} ${proteome}

		grep -o '^[^#]*' ${proteome.baseName}.out > ${proteome.baseName}.tsv
	"""
}