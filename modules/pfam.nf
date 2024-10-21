process DownloadPfam {
    
	/*
	* Processus : suppression des séquences fasta qui n'apparaissent qu'une seul foit dans le fichier d'alignement
	* cela signifie que les séquences se sont uniquement aligné contre elle même
    *
    * Input:
    * 	- fichier d'alignement tsv issu de diamond balstp
    * Output:
    *	- fichier d'alignement tsv
    */

	tag ''

   	//publishDir "$baseDir/bin", mode: 'copy', pattern: "assign_cath_superfamilies.py"

	label 'lagoon'

	output:
	    path "Pfam-A.hmm", emit: hmms

	script:
	"""
		wget -c https://ftp.ebi.ac.uk/pub/databases/Pfam/releases/Pfam37.1/Pfam-A.hmm.gz
		gzip -d Pfam-A.hmm.gz
    """
}

//http://download.cathdb.info/cath/releases/latest-release/cath-classification-data/cath-domain-list.txt

process HMMsearch {
    
	/*
	* Processus : suppression des séquences fasta qui n'apparaissent qu'une seul foit dans le fichier d'alignement
	* cela signifie que les séquences se sont uniquement aligné contre elle même
    *
    * Input:
    * 	- fichier d'alignement tsv issu de diamond balstp
    * Output:
    *	- fichier d'alignement tsv
    */

	tag ''

	label 'hmmer'

	input:
        each path(fasta)
		path hmms
        //path gene3d

	output:
        path "${fasta.baseName}.tsv", emit: hmmsearch

	script:
	"""
		hmmsearch \
			--tblout ${fasta.baseName}.out \
			-o ${fasta.baseName}.hmmsearch ${hmms} ${fasta}

		grep -o '^[^#]*' ${fasta.baseName}.out > ${fasta.baseName}.tsv
	"""
}
/*
process PfamAnalysis {

	tag ''

	label 'cath'

	input:
		path pfam_annotation

	output:
		tuple path("class.tsv"), path("architecture.tsv"), path("topology.tsv"), path("superfamily.tsv") emit: tuple_cath

	script:
	"""
		cut -d "," -f 1 ${superfamilies} > col4
		cut -d "." -f 1,2,3 col4 > col3
		cut -d "." -f 1,2 col4 > col2
		cut -d "." -f 1 col4 > col1

		sed -i '1s/^/class,architecture,topology,superfamily,${params.peptides_column}\n/' file

		paste -d "," col1 col2 col3 ${superfamilies} > classification.csv
		
		sed 's/,/\t/g' classification.csv > classification.tsv

		cut -f 1,5 classification.tsv > class.tsv
		cut -f 2,5 classification.tsv > architecture.tsv
		cut -f 3,5 classification.tsv > topology.tsv
		cut -f 4,5 classification.tsv > superfamily.tsv
	"""

}
*/

//cath_analysis.R classification.csv

//sed -i 's/"//g' classification.tsv
