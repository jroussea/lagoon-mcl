process CathResolveHits {
    
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

	label 'cath'

	input:
        each path(hmmsearch)

	output:
        path("${hmmsearch.baseName}.crh"), emit: cath_resolve_hits

	script:
	"""
    	cath-resolve-hits \
			--min-dc-hmm-coverage=80 \
			--worst-permissible-bitscore 25 \
			--output-hmmer-aln \
			--input-format hmmsearch_out ${hmmsearch} > ${hmmsearch.baseName}.crh
	"""
}

process AssignSuperfamilies {
    
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

	label 'cath'

	publishDir "${params.outdir}/cath", mode: 'copy', pattern: "${cath_resolve_hits}.csv"

	input:
        each path(cath_resolve_hits)
		path(cath_domain_list)
		path(discontinuous_regs)

	output:
        path("${cath_resolve_hits}.csv"), emit: superfamilies

	script:
	"""
        assign_cath_superfamilies.py \
			${cath_resolve_hits} \
			0.001 with_family \
			${discontinuous_regs} \
			${cath_domain_list}
    """
}

process SelectSuperfamilies {

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

	label 'cath'

	input:
		each path(superfamilies)

	output:
        path("${superfamilies.baseName}"), emit: select_cath


	script:
	"""
		sed -i '1d' ${superfamilies} 

		cut -d "," -f 3 ${superfamilies} > col1
		cut -d "," -f 2 ${superfamilies} > col2

		paste -d "\t" col1 col2 > ${superfamilies.baseName}

	"""

}

process CathAnalysis {

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

	label 'cath'

	input:
		path(superfamilies)

	output:
		path("classification.tsv"), emit: classification

	script:
	"""
		cut -f 1 ${superfamilies} > col1
		cut -f 2 ${superfamilies} > col5
		cut -d "." -f 1,2,3 col5 > col4
		cut -d "." -f 1,2 col5 > col3
		cut -d "." -f 1 col5 > col2

		paste -d "," col1 col2 col3 col4 col5 > classification
		echo "protein_accession,class,architecture,topology,superfamily" > header
		cat header classification > classification.csv
		
		cat classification.csv | tr ',' '\t' > classification.tsv
	"""

}

process PreparationCath {

    /*
	* DESCRIPTION
    * -----------
    *   Préparation des annotation CATH / Gene3D
    *   Création d'un fichier par niveau dans la classification CATH
    *   Class, Architecture, Topology, Superfamily
    * 
    * INPUT
    * -----
    * 	Fichier TSV à deux colonnes
    *       - colonne 1 : identifiant / nom des séquences
    *       - colonne 2 : idenfiant de l'annotation CATH pour chaque séquence
    *
    * OUPUT
    * -----
    *	4 fichier TSV (1 pour chaque niveau dans la classification)
    *   Contiennent 2 colonne
    *       - colonne 1 : identifiant / nom des séquences
    *       - colonne 2 : identifiant dans la classification (spécifique à un niveau)
    */

	tag ''

	label 'lagoon'

	input:
		path(select_annotation)
		val(columns_attributes)
		val(type)

	output:
		path("*.tsv"), emit: label_cath

	script:

		"""
		label_gene3d.py --annotation ${select_annotation} --labels ${columns_attributes}
		"""
}