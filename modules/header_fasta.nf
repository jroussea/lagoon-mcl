process HeaderFasta {

	tag "Step 2"

	label "general_setting"

	//publishDir "${params.outdir}/diamond", mode: 'copy', pattern: 'reference.dmnd'

	input:
        path proteome
		//path annotation
    	//path cor_table

	output:
        path "${proteome.baseName}.name", emit: proteome_name
    	//path "reference.dmnd", emit: diamond_reference

	script:
		"""
	    seqkit seq -n $proteome > ${proteome.baseName}.name
		"""
}