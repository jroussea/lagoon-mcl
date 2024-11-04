process PreparationPfam {

    /*
	* DESCRIPTION
    * -----------
    *   Préparation d'un tableau à deux colonne à partir du tableau généré par hmmsearch
    *
    * INPUT
    * -----
    * 	ficheir (séprateur de colonne : espace), généré par hmmsearch
    *
    * OUPUT
    * -----
    *	Ficheier TSV à 2 colonnes
    *       - colonne 1 : identifiant / nom de la séquence
    *       - colonne 2 : identifiant Pfam
    */

	label 'lagoon'

	input:
		path(search_m8)

	output:
		path("${search_m8.baseName}.pfam"), emit: select_pfam

	script:

		"""
		cut -d "." -f 1 ${search_m8} > ${search_m8.baseName}.pfam
		"""

    stub:
		"""
        touch pfam.tsv
		"""
}