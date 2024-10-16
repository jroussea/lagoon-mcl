process DownloadAlphafoldDB {
    
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

process FiltrationAlnStructure {
    
    tag ''

	label 'lagoon'

	publishDir "${params.outdir}", mode: 'copy', pattern: "${structure_aln.baseName}_alignment.tsv"

    input:
        path structure_aln

    output:
        path "${structure_aln.baseName}_alignment.tsv", emit: structure

    script:
        """
        cut -f 1,5,10,13 ${structure_aln} > structure.aln

        filtration_diamond_blastp_structure.py structure.aln

        cut -f 1 filter_*.aln > col1 
        cut -f 2 filter_*.aln > col2

        paste col2 col1 > ${structure_aln.baseName}_alignment.tsv
        """
}

/*
process StatStructure {

    tag ''

    label 'lagoon'

    input:
        path structure
        tuple path(network_tsv), val(inflation)
        val peptides_column
        val type

    output:
        stdout

    script:
        """
        statistics_structure.py ${peptides_column} ${structure} {network_tsv} {inflation} ${structure.baseName}
        """
}
*/
