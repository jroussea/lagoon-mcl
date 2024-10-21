process TestProcess {
	
	tag ''
	
	label 'lagoon'

	input:
		tuple path(liste), val(inflation), val(annot)

	output:
		stdout

	script:

		"""
		echo ${liste}

        echo ${inflation}

        echo ${annot}
		"""
}