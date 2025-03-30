process HomogeneityScore {

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

    publishDir "${params.outdir}/lagoon-mcl_output/${network_tsv.baseName}/clusters", mode: 'copy', pattern: "clusters_labels_network_I*.tsv"
    publishDir "${params.outdir}/lagoon-mcl_output/abundance_matrix", mode: 'copy', pattern: "abundance_matrix_*_network_I*.json"

    input:
        path(label_network)
        each path(network_tsv)
    
    output:
        tuple val("${network_tsv.baseName}"), path("homogeneity_score_*.tsv"), emit: tuple_hom_score
        path("abundance_matrix_*_network_I*.json")
        path("clusters_labels_network_I*.tsv")

    script:
        """
        homogeneity_score.py --network ${network_tsv} --labels ${label_network} --basename ${network_tsv.baseName}
        """

    stub:
		"""
        touch homogeneity_score_${label_network.baseName}_I${inflation}.tsv
        touch ${label_network.baseName}.txt
		"""
}

process NodesFiles {

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

    publishDir "${params.outdir}/lagoon-mcl_output/${network}/igraph", mode: 'copy', pattern: "edges_igraph_network_I*.tsv"
    publishDir "${params.outdir}/lagoon-mcl_output/${network}/igraph", mode: 'copy', pattern: "nodes_igraph_network_I*.tsv"
    publishDir "${params.outdir}/lagoon-mcl_output/${network}/nodes", mode: 'copy', pattern: "nodes_labels_network_I*.tsv"
    publishDir "${params.outdir}/lagoon-mcl_output/${network}/nodes", mode: 'copy', pattern: "nodes_metrics_network_I*.tsv"

    input: 
        tuple val(network), path(nodes_infos)

    output:
        path("edges_igraph_network_I*.tsv")
        path("nodes_igraph_network_I*.tsv")
        path("nodes_labels_network_I*.tsv")
        path("nodes_metrics_network_I*.tsv")
        tuple val("${network}"), path("diameter_*.json"), emit: tuple_json_diameter
        tuple val("${network}"), path("nodes_metrics_network_I*.tsv"), emit: tuple_nodes_metrics

    script:
        """
        nodes_files.py --network edges_network_I*.tsv --information node_annotation_network_I*.tsv --alphafold network_I*_alphafold_cluster.tsv --basename ${network}
        """
}

process ClustersFiles {

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

    publishDir "${params.outdir}/lagoon-mcl_output/${network}/clusters", mode: 'copy', pattern: "clusters_metrics_network_I*.tsv"

    input:
        tuple val(network), path(clusters_infos)

    output:
        path("clusters_metrics_network_I*.tsv")
        tuple val("${network}"), path("clusters_metrics_network_I*.tsv"), emit: tuple_clusters_metrics

    script:
        """
        clusters_files.py --diameter diameter_network_I*.json --hom_sc homogeneity_score_network_I*.tsv --basename ${network}
        """
}

process HtmlReports {

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

    publishDir "${params.outdir}/lagoon-mcl_output/reports", mode: 'copy', pattern: "figures_${network}/*"
    publishDir "${params.outdir}/lagoon-mcl_output/reports", mode: 'copy', pattern: "report_${network}.html"

    input:
        tuple val(network), path(metrics)

    output:
        path("figures_${network}/*")
        path("report_${network}.html")

    script:
        """
        mkdir figures_${network}/
        report.py --nodes nodes_metrics_network_I*.tsv --clusters clusters_metrics_network_I*.tsv --edges edges_network_I*.tsv --template ${projectDir}/html_templates --basename ${network}
        """
}