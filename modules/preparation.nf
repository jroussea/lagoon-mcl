process HeaderFasta {
	
	label 'darkdino'

	input:
		path all_sequences

	output:
		path "${params.concat_fasta}.rename.fasta", emit: fasta_rename
	
	script:

		"""
		sed -E '/^>/s/( +|\t).*//' ${all_sequences} > "${params.concat_fasta}.rename.fasta"
		"""
}