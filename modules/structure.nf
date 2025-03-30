process AlphafoldAlignment {

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
        tuple path(alphafold_aln), val(database)

    output:
        path("alphafold_alignment_selection.tsv"), emit: alphafold_aln_filter

    script:
        """
        alphafold_alignment.py --alignment ${alphafold_aln}
        """
}

process AlphafoldNetwork {

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
        each path(network)
        path(uniprot)
        path(alignment)
    
    output:
        tuple val(network.baseName), path("*_alphafold_cluster.tsv"), emit: tuple_alphafold
    
    script:
        """
        wget https://afdb-cluster.steineggerlab.workers.dev/1-AFDBClusters-entryId_repId_taxId.tsv.gz
        gunzip 1-AFDBClusters-entryId_repId_taxId.tsv.gz
        alphafold_network.py --clusters 1-AFDBClusters-entryId_repId_taxId.tsv --uniprot ${uniprot} --alignment ${alignment} --network ${network} --basename ${network.baseName}
        """
}

process AlphafoldInformations {

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
        path(uniprot)
        path(alignment)
    
    output:
        tuple val("alphafold_id"), path("label_alphafold_identifier.tsv"), emit: alphafold_id
        tuple val("alphafold_clst"), path("label_alphafold_cluster_id.tsv"), emit: alphafold_clst
        tuple val("alphafold_pfam"), path("label_alphafold_pfam_id.tsv"), emit: alphafold_pfam
    
    script:
        """
        wget https://afdb-cluster.steineggerlab.workers.dev/1-AFDBClusters-entryId_repId_taxId.tsv.gz
        gunzip 1-AFDBClusters-entryId_repId_taxId.tsv.gz
        alphafold_informations.py --clusters 1-AFDBClusters-entryId_repId_taxId.tsv --uniprot ${uniprot} --alignment ${alignment}
        """
}

