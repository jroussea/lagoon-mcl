process ALPHAFOLD_ALIGNMENTS {

    /*
	* DESCRIPTION
    * -----------
    * Selection of a single alignment per sequence pair
    *
    * INPUT
    * -----
    * 	- alphafold_aln: alignment obtained after MMseqs2
    *
    * OUPUT
    * -----
    *	- alphafold_alignment_selection.tsv: filtered file
    */

    label 'lagoon'

    publishDir "${params.outdir}/lagoon-mcl_output/alignments", mode: 'copy', pattern: "mmseqs2_alpahfold_clusters_alignments.selection.tsv"

    input:
        path(alphafold_alignments)

    output:
        path("mmseqs2_alpahfold_clusters_alignments.selection.tsv"), emit: alphafold_alignments_filter

    script:
        """
        alphafold_alignments.py --alignment ${alphafold_alignments}
        """
}

process ALPHAFOLD_INFORMATIONS {

    /*
	* DESCRIPTION
    * -----------
    * Retrieve Pfam annotations specific to AlphaFold sequences in InterPro
    * Recovery of AlphaFold cluster identifiers
    *
    * INPUTALPHAFOLD_ALIGNMENTS
    * -----
    * 	- uniprot: JSON file containing Pfam annotations linked to AlphaFold/UniProt sequence identifiers
    *   - alignments: sequence alignment against the AlphaFold clusters database
    *
    * OUPUT
    * -----
    *	- label_alphafold_identifier.tsv: user-provided sequence annotation file with sequence identifiers from the AlphaFold clusters database
    *   - label_alphafold_cluster_id.tsv: user-supplied sequence annotation file with AlphaFold clusters database identifiers
    *   - label_alphafold_pfam_id.tsv: user-provided sequence annotation file with Pfam annotations available in InterPro and linked to sequences in the AlphaFold clusters database
    */

    label 'lagoon'

    input:
        path(uniprot)
        path(alignments)

    output:
        tuple val("alphafold_sequences"), path("alphafold_sequences.tsv"), emit: alphafold_sequences_id
        tuple val("alphafold_clusters"), path("alphafold_clusters.tsv"), emit: alphafold_clusters_id
        tuple val("alphafold_pfam"), path("alphafold_pfam.tsv"), emit: alphafold_pfam

    script:
        """
        wget https://afdb-cluster.steineggerlab.workers.dev/1-AFDBClusters-entryId_repId_taxId.tsv.gz
        gunzip 1-AFDBClusters-entryId_repId_taxId.tsv.gz
        alphafold_informations.py --clusters 1-AFDBClusters-entryId_repId_taxId.tsv --uniprot ${uniprot} --alignment ${alignments}
        """
}

