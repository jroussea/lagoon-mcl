process DownloadGene3D {
    
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
	    path "hmms/main.hmm", emit: hmms
		path "cath-domain-list.txt", emit: cath_domain_list
		path "discontinuous_regs.pkl", emit: discontinuous_regs

	script:
	"""
		wget -c http://download.cathdb.info/gene3d/CURRENT_RELEASE/gene3d_hmmsearch/hmms.tar.gz
		tar -xvf hmms.tar.gz

		wget -c http://download.cathdb.info/cath/releases/latest-release/cath-classification-data/cath-domain-list.txt
		
		wget -c http://download.cathdb.info/gene3d/CURRENT_RELEASE/gene3d_hmmsearch/discontinuous/discontinuous_regs.pkl		
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
        path "${fasta.baseName}.hmmsearch", emit: hmmsearch

	script:
	"""
    	hmmsearch \
			-Z 10000000 \
			--domE 0.001 \
			--incdomE 0.001 \
			--cpu ${task.cpus} \
			-o ${fasta.baseName}.hmmsearch ${hmms} ${fasta}
	"""
}
/*
    	hmmsearch \
			-Z 10000000 \
			--domE 0.001 \
			--incdomE 0.001 \
			-o ${fasta.baseName}.hmmsearch ${baseDir}/CATH_Gene3D/hmms/main.hmm ${fasta}
*/

process CathResolveHits {
    
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

	label 'cath'

	input:
        each path(hmmsearch)

	output:
        path "${hmmsearch.baseName}.crh", emit: cath_resolve_hits

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
	* Processus : suppression des séquences fasta qui n'apparaissent qu'une seul foit dans le fichier d'alignement
	* cela signifie que les séquences se sont uniquement aligné contre elle même
    *
    * Input:
    * 	- fichier d'alignement tsv issu de diamond balstp
    * Output:
    *	- fichier d'alignement tsv
    */

	tag ''

	label 'cath'

	publishDir "${params.outdir}/cath", mode: 'copy', pattern: "${cath_resolve_hits}.csv"

	input:
        each path(cath_resolve_hits)
		path cath_domain_list
		path discontinuous_regs

	output:
        path "${cath_resolve_hits}.csv", emit: superfamilies

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

	tag ''

	label 'cath'

	input:
		each path(superfamilies)

	output:
        path "${superfamilies.baseName}", emit: select_cath


	script:
	"""
		sed -i '1d' ${superfamilies} 

		cut -d "," -f 2,3 ${superfamilies} > intermediate

		cat intermediate | tr ',' '\t' > ${superfamilies.baseName}
	"""

}

process CathAnalysis {

	tag ''

	label 'cath'

	input:
		path superfamilies

	output:
		path("classification.tsv"), emit: classification

	script:
	"""
		cut -f 1 ${superfamilies} > col5
		cut -f 2 ${superfamilies} > col1
		cut -d "." -f 1,2,3 col5 > col4
		cut -d "." -f 1,2 col5 > col3
		cut -d "." -f 1 col5 > col2

		paste -d "," col1 col2 col3 col4 col5 > classification
		echo "${params.peptides_column},class,architecture,topology,superfamily" > header
		cat header classification > classification.csv
		
		cat classification.csv | tr ',' '\t' > classification.tsv
	"""

}
//		sed -i '1s/^/class,architecture,topology,superfamily,${params.peptides_column}\n/' classification.csv


//cath_analysis.R classification.csv

//sed -i 's/"//g' classification.tsv
//		sed 's/,/\t/g' classification.csv > classification.tsv
/*
		cut -f 1,5 classification.tsv > class.tsv
		cut -f 2,5 classification.tsv > architecture.tsv
		cut -f 3,5 classification.tsv > topology.tsv
		cut -f 4,5 classification.tsv > superfamily.tsv
*/