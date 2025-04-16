process HOMOGENEITY_SCORE {

    /*
	* DESCRIPTION
    * -----------
    * Calculate homogeneity score
    *
    * INPUT
    * -----
    * 	- label_network:  TSV file containing all annotations
    *   - network: TSV file containing the network
    *
    * OUPUT
    * -----
    *	- network_I*_homogeneity_score.tsv: tsv file containing homogeneity scores for each cluster and annotation
    *   - network_I*_abundance_matrix.json: annotation abundance matrix for each cluster
    *   - network_I*_clusters_annotations.tsv: list of annotations that can be found in each cluster
    */

    label 'lagoon'

    publishDir "${params.outdir}/lagoon-mcl_output/${network.baseName}/clusters", mode: 'copy', pattern: "network_I*_clusters_annotations.tsv"
    publishDir "${params.outdir}/lagoon-mcl_output/abundance_matrix", mode: 'copy', pattern: "network_I*_abundance_matrix.json"

    input:
        path(label_network)
        each path(network)
    
    output:
        tuple val("${network.baseName}"), path("network_I*_homogeneity_score.tsv"), emit: tuple_hom_score
        path("network_I*_abundance_matrix.json")
        path("network_I*_clusters_annotations.tsv")

    script:
        """
        homogeneity_score.py --network ${network} --labels ${label_network} --basename ${network.baseName}
        """
}

process SEQUENCES_FILES {

    /*
	* DESCRIPTION
    * -----------
    * Sequence-specific file creation
    *
    * INPUT
    * -----
    *   - network: network name
    *   - nodes_infos: TSV file containing sequence-specific information
    *
    * OUPUT
    * -----
    *	- network_I*_sequences_annotations.tsv: list of sequence-related anntoations
    *   - network_I*_sequences_metrics.tsv: sequence-specific metrics (length, centrality, number of annotations, etc.)
    *   - network_I*_diameters.json: cluster diameter
    */

    label 'lagoon'

    publishDir "${params.outdir}/lagoon-mcl_output/${network}/sequences", mode: 'copy', pattern: "network_I*_sequences_annotations.tsv"
    publishDir "${params.outdir}/lagoon-mcl_output/${network}/sequences", mode: 'copy', pattern: "network_I*_sequences_metrics.tsv"

    input: 
        tuple val(network), path(nodes_infos)

    output:
        path("network_I*_sequences_annotations.tsv")
        path("network_I*_sequences_metrics.tsv")
        tuple val("${network}"), path("network_I*_diameters.json"), emit: tuple_json_diameter
        tuple val("${network}"), path("network_I*_sequences_metrics.tsv"), emit: tuple_sequences_metrics

    script:
        """
        sequences_files.py --network network_I*_edges.tsv --information network_I*_sequences_annotations_preprocessing.tsv --basename ${network}
        """
}

process CLUSTERS_FILES {

    /*
	* DESCRIPTION
    * -----------
    * Cluster-specific file creation
    *
    * INPUT
    * -----
    *   - network: network name
    *   - clusters_infos: TSV file containing cluster-specific information
    *
    * OUPUT
    * -----
    *	- network_I*_clusters_metrics.tsv: TSV file containing cluster metrics (number of sequences, diameter, homogeneity score, etc.)
    */

    label 'lagoon'

    publishDir "${params.outdir}/lagoon-mcl_output/${network}/clusters", mode: 'copy', pattern: "network_I*_clusters_metrics.tsv"

    input:
        tuple val(network), path(clusters_infos)

    output:
        path("network_I*_clusters_metrics.tsv")
        tuple val("${network}"), path("network_I*_clusters_metrics.tsv"), emit: tuple_clusters_metrics

    script:
        """
        clusters_files.py --diameter network_I*_diameters.json --homogeneity_score network_I*_homogeneity_score.tsv --basename ${network}
        """
}

process HTML_REPORT {

    /*
	* DESCRIPTION
    * -----------
    * Generates an HTML report
    *
    * INPUT
    * -----
    *   - network: network name
    *   - metrics: tous les fichiers contenants des métriques
    *       - sequences_metrics_network_I[inflation].tsv
    *       - clusters_metrics_network_I[inflation].tsv
    *       - edges_network_I[inflation].tsv
    *
    * OUPUT
    * -----
    *	- network_I*_figures/*: contains all PNG figures of the report
    *   - network_I*_report.html: HTML report
    */

    label 'lagoon'

    publishDir "${params.outdir}/lagoon-mcl_output/reports", mode: 'copy', pattern: "${network}_figures/*"
    publishDir "${params.outdir}/lagoon-mcl_output/reports", mode: 'copy', pattern: "${network}_report.html"

    input:
        tuple val(network), path(metrics)

    output:
        path("${network}_figures/*")
        path("${network}_report.html")

    script:
        """
        mkdir ${network}_figures/
        html_report.py --nodes network_I*_sequences_metrics.tsv --clusters network_I*_clusters_metrics.tsv --edges network_I*_edges.tsv --template ${projectDir}/html_templates --basename ${network}
        """
}