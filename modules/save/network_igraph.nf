process NetworkIgraph {

	tag "Step 8.2.1"

	label "igraph"

	publishDir "${params.outdir}/network/igraph", mode: 'copy', pattern: "statistics*"
   	publishDir "${params.outdir}/network/igraph", mode: 'copy', pattern: "network_igraph*"
   	publishDir "${params.outdir}/network/igraph", mode: 'copy', pattern: "*.graphml"
   	publishDir "${params.outdir}/network/igraph", mode: 'copy', pattern: "*.pickle"

	input:
		path diamond_ssn

	output:
        //stdout
        path "statistics*"
        path "network_igraph*"
		path "*.graphml"
		path "*.pickle"

	script:
	"""

    network_igraph.py ${diamond_ssn} ${params.max_weight} ${params.min_cc_size}

	"""
}
