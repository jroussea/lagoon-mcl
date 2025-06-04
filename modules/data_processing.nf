process FASTA_PROCESSING {

    /*
	* DESCRIPTION
    * -----------
    * Preparation of fasta files (keeps sequence IDs in headers)
    *
    * INPUT
    * -----
    * 	- User-supplied fasta files
    *
    * OUPUT
    * -----
    *	- fasta_sequences_renamed.fasta: modified fasta file
    */

    label 'lagoon'

    input:
        path(sequence)

    output:
		path("fasta_sequences_renamed.fasta"), emit: sequences_renamed

    script:
        """
		files_processing.py --fasta ${sequence} --fasta_output fasta_sequences_renamed.fasta --processing fasta
        """
}

process ANNOTATIONS_PROCESSING {

    /*
	* DESCRIPTION
    * -----------
    * Preparation of user-supplied annotation files
    * Add sequences without annotations, assigning NA as label
    * Add a third sequence containing the annotation type (e.g. Pfam)
    *
    * INPUT
    * -----
    * 	- fasta: renamed fasta file 
    *   - annotation: annotation type
    *   - file: TSV file containing annotations
    *
    * OUPUT
    * -----
    *	- labels_[annotation type].tsv: modified TSV file containing annotations
    */

    label 'lagoon'

    input:
        each path(fasta)
        tuple val(annotations), path(file)
    
    output:
		path("labels_${annotations}.tsv"), emit: annotations_files

    script:
        """
        files_processing.py --labels ${file} --fasta ${fasta} --database ${annotations} --processing labels
        """
}

process FILTER_ALIGNMENTS {
    
	/*
	* DESCRIPTION
	* -----------
	* Keeps only one alignment per sequence pair
    *
    * INPUT
	* -----
    * 	- diamond_alignment: file containing pairwise alignments obtained with Diamond BLASTp
    *
	* OUTPUT
	* ------
    *	- diamond_alignment.filter.tsv: TSV file containing a single alignment per sequence pair
    */

	label 'lagoon'

    publishDir "${params.outdir}/lagoon-mcl_output/alignments", mode: 'copy', pattern: "diamond_alignments.filter.tsv"
    publishDir "${params.outdir}/lagoon-mcl_output/alignments", mode: 'copy', pattern: "mcl_input_file.tsv"

	input:
        path(diamond_alignment)

	output:
        path("diamond_alignments.filter.tsv"), emit: diamond_ssn
        path("mcl_input_file.tsv"), emit: mcl_input_file

	script:
		"""
        filter_alignments.py --alignment ${diamond_alignment}
		"""
}

process SEQUENCES_PROCESSING {

    /*
	* DESCRIPTION
    * -----------
    * Preparation of files containing the sequences present in the networks
    *
    * INPUT
    * -----
    * 	- fasta: renamed fasta file 
    *   - network: network file
    *   - labels: annotations/labels files
    *
    * OUPUT
    * -----
    *	- network_I*_sequences_annotations_preprocessing.tsv: annotation files containing only sequences present in a network
    */

    label 'lagoon'

    input:
        path(fasta)
        each path(network)
        path(labels)

    output:
        tuple val(network.baseName), path("network_I*_sequences_annotations_preprocessing.tsv"), emit: tuple_node_labels

    script:
        """
        files_processing.py --network ${network} --labels ${labels} --basename ${network.baseName} --fasta ${fasta} --processing nodes
        """
}

process PFAM_PROCESSING {

    /*
	* DESCRIPTION
    * -----------
    *
    * INPUT
    * -----
    *   - search_m8: alignment file obtained with MMseqs2
    *   - fasta: user fasta files
    *
    * OUPUT
    * -----
    *   - pfamDB.tsv: sequence annotation file with Pfam database
    *   - mmseqs2_pfam_database_alignments.tsv: MMseqs2 alignment file saved in the alignments folder
    */

    label 'lagoon'

    publishDir "${params.outdir}/lagoon-mcl_output/alignments", mode: 'copy', pattern: "mmseqs2_pfam_database_alignments.m8"

    input:
        path(search_m8)
        path(fasta)
        
    output:
        path("mmseqs2_pfam_database_alignments.m8")
        path("pfamDB.tsv"), emit: pfam_files

    script:
        """
        cp ${search_m8} mmseqs2_pfam_database_alignments.m8
        files_processing.py --pfam_scan ${search_m8} --fasta ${fasta} --database pfamDB --processing pfam
        """
}

process SORT_FASTA {

    /*
	* DESCRIPTION
    * -----------
    * Preparation of fasta files (keeps sequence IDs in headers)
    *
    * INPUT
    * -----
    * 	- User-supplied fasta files
    *
    * OUPUT
    * -----
    *	- fasta_sequences_renamed.fasta: modified fasta file
    */

    label 'lagoon'

    input:
        path(sequence)

    output:
		path("fasta_sequences_renamed_sort.fasta"), emit: sequences_sort

    script:
        """
		sort_fasta_file.py --input ${sequence} --output fasta_sequences_renamed_sort.fasta
        """
}

