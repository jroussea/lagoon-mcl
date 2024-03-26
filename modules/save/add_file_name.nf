process AddFileName {

	tag ""

	label "seqkit"

	//publishDir "${params.outdir}/diamond", mode: 'copy', pattern: 'reference.dmnd'

	input:
        path proteome
        path cor_table
	//	path annotation
    //    path cor_table

	output:
        path "${params.concat_fasta}.correspondence_table", emit: cor_table
    //    path "reference.dmnd", emit: diamond_reference

	script:
	"""

    seqkit seq -n $proteome > ${proteome}.name.lst

    merge_2_dataframe ${proteome.baseName} ${proteome}.name.lst ${cor_table}

	"""
}