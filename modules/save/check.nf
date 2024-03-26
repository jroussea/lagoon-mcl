process Check {

	tag ""

	output:
		path "${m2d_cor_table.baseName}.sequence_id.tsv", emit: annot_seq_id

	script:

def helpMessage() {
	log.info ABIHeader()
	log.info """
	DARKDINO project: Annotation fonctionnelle
	
	- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	
	Description: Nextflow workflow pour faire de l'annotation fonctionnelle
	
	=============================================================================


			The typical command to run the pipeline is:
				nextflow run main.nf -c nextflow.config -profile custom,singularity [params]
	



		Setting [params]
	Mandatory:
	Optional:

	"""
}

def logInformations() {
	log.info """\
	DARKDINO MCL
	===================================================
	General informations
		projectName                 : ${params.projectName}
		fasta                       : ${params.fasta}
		annotation                  : ${params.annotation}
		concatenated fasta files    : ${params.concat_fasta}
	
	Diamond informations
		diamond database            : ${params.diamond_db}
		diamond alignment           : ${params.diamond}
		sensitivity (blastp)        : ${params.sensitivity}
		matrix (blastp)             : ${params.matrix}
		evalue (blastp)             : ${params.evalue}
		
	Diamond pairwise alignment analysis
		Filtering alignments        : ${params.filter}
		minimum identity percentage : ${params.flt_id}
		minimum overlap percentage  : ${params.flt_ov}
		evalue maximum              : ${params.flt_ev}


		${params.max_weight}
	"""
}

if (params.help) {
	helpMessage()
	exit 0
}
if (params.sensitivity != "fast"
	&& params.sensitivity != "mid-sensitive"
	&& params.sensitivity != "more-sensitive"
	&& params.sensitivity != "very-sensitive"
	&& params.sensitivity != "sensitive"
	&& params.sensitivity != "ultra-sensitive") {
	helpMessage()
	exit 0
}
if (params.matrix != "BLOSUM45"
	&& params.matrix != "BLOSUM50"
	&& params.matrix != "BLOSUM62"
	&& params.matrix != "BLOSUM80"
	&& params.matrix != "BLOSUM90"
	&& params.matrix != "PAM250"
	&& params.matrix != "PAM70"
	&& params.matrix != "PAM30") {
	helpMessage()
	exit 0
}
if (params.evalue instanceof java.lang.String) {
	helpMessage()
	exit 0
}
if (params.evalue > 1 || params.evalue < 0) {
	helpMessage()
	exit 0
}
if (params.filter != true && params.filter != false) {
	helpMessage()
	exit 0
}
if (params.flt_id instanceof java.lang.String) {
	helpMessage()
	exit 0
} 
if (params.flt_id > 100 || params.flt_id < 0) {
	helpMessage()
	exit 0
}
if (params.flt_ov instanceof java.lang.String) {
	helpMessage()
	exit 0
}
if (params.flt_ov > 100 || params.flt_ov < 0) {
	helpMessage()
	exit 0
}
if (params.flt_ev instanceof java.lang.String) {
	helpMessage()
	exit 0
}
if (params.flt_ev > 1 || params.flt_ev < 0) {
	helpMessage()
	exit 0
}
if (params.igraph != true && params.igraph != false) {
	helpMessage()
	exit 0
} 
if (params.max_weight instanceof java.lang.String) {
	helpMessage()
	exit 0
}
if (params.min_cc_size instanceof java.lang.String || params.min_cc_size instanceof java.lang.Double) {
	helpMessage()
	exit 0
}
if (params.min_cc_size < 1) {
	helpMessage()
	exit 0
}

	"""
	"""
}