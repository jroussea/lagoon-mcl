process DownloadGene3D {
    
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

	label 'lagoon'

	output:
	    path("hmms/main.hmm"), emit: hmms
		path("cath-domain-list.txt"), emit: cath_domain_list
		path("discontinuous_regs.pkl"), emit: discontinuous_regs

	script:
	"""
		wget -c http://download.cathdb.info/gene3d/CURRENT_RELEASE/gene3d_hmmsearch/hmms.tar.gz
		tar -xvf hmms.tar.gz

		wget -c http://download.cathdb.info/cath/releases/latest-release/cath-classification-data/cath-domain-list.txt
		
		wget -c http://download.cathdb.info/gene3d/CURRENT_RELEASE/gene3d_hmmsearch/discontinuous/discontinuous_regs.pkl		
    """
}

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

	tag ''

	label 'lagoon'

	output:
	    path("Pfam-A.hmm"), emit: hmms

	script:
	"""
		wget -c https://ftp.ebi.ac.uk/pub/databases/Pfam/releases/Pfam37.1/Pfam-A.hmm.gz
		gzip -d Pfam-A.hmm.gz
    """
}

process DownloadAlphafoldDB {
    
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
    
	label 'lagoon'

    output:
        //stdout
        path "sequences.fasta", emit: alfafoldSequence

    script:
        """
        wget -c ftp.ebi.ac.uk/pub/databases/alphafold/sequences.fasta
        """
}

process DownloadESMatlas {
    
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
    
	label 'lagoon'

    output:
        //stdout
        path "highquality_clust30.fasta", emit: esmSequence

    script:
        """
        wget -c https://dl.fbaipublicfiles.com/esmatlas/v0/highquality_clust30/highquality_clust30.fasta
        """
}