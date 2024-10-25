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

	tag ''

	label 'lagoon'

	input:
		path(all_pfam)

	output:
		path("pfam.tsv"), emit: label_pfam

	script:

		"""
		label_pfam.R ${all_pfam}

		cut -f 1 pfam > col1
		cut -f 2 pfam | cut -d "." -f 1 > col2
		cut -f 3 pfam > col3

		paste col1 col2 col3 > pfam.tsv
		"""
}