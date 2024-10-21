process PrepaAnnotation {

    label 'lagoon'

    input:
        path annotation

    output:
        stdout

    script:
        """
        annotation_preparation.R ${annotation} ${annotation.baseName}
        """
}

process PreparationCath {

	tag ''

	label 'lagoon'


	publishDir "${params.outdir}/network/labels/${type}", mode: 'copy', pattern: "*.tsv"

	input:
		path select_annotation
		val columns_attributes
		val type

	output:
		path("*.tsv"), emit: label_cath

	script:

		"""
		label_gene3d.py ${select_annotation} ${columns_attributes} ${params.peptides_column}
		"""
}

process PreparationPfam {

	tag ''

	label 'lagoon'


	//publishDir "${params.outdir}/network/labels/${type}", mode: 'copy', pattern: "*.tsv"

	input:
		path all_pfam

	output:
		path("pfam.tsv"), emit: label_pfam

	script:

		"""
		label_pfam.R ${all_pfam}

		cut -f 1 pfam > col1
		cut -f 2 pfam | cut -d "." -f 1 > col2
		cut -f 3 pfam > col3

		paste col1 col2 col3 > pfam.tsv
		"""
}

process PreparationAnnot {

    label 'lagoon'

    input:
        path annotation
    
    output:
        //stdout
		path("${annotation.baseName}.tsv"), emit: label_annotation
    
    script:
        """
		mv ${annotation} intermediate

        label_annotation.R intermediate ${annotation.baseName}
        """
}