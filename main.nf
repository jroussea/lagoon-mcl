#!/usr/bin/env nextflow

// Enable modules
nextflow.enable.dsl = 2

def helpMessage() {
	log.info ABIHeader()
	log.info """
	
	LAGOON-MCL

	For more information, see the documentation: 
	=============================================================================================

	--max_cpus
	--max_memory
	--max_time

	--projectName
	--outdir

	--fasta

	--scan_pfam
	--pfam_db
	--pfam_name

	--alignment_file
	--sensitivity
	--matrix
	--diamond_evalue

	--I
	--max_weight
	--cluster_size

	Examples:

	Test parameters:
		nextflow run main.nf -profile singularity [params]
	
	Custom parameters:
		nextflow run main.nf -profile singularity [params]
	"""
}

if (params.help) {
	helpMessage()
	exit 0
}

// PIPELINE INFO
// Header log info
def summary = [:]
if (workflow.revision) summary['Pipeline Release'] = workflow.revision
summary['Run Name'] = workflow.runName
summary['Project Name'] = params.projectName
summary['Output dir'] = params.outdir
summary['Launch dir'] = workflow.launchDir
summary['Working dir'] = workflow.workDir
summary['Script dir'] = workflow.projectDir
summary['User'] = workflow.userName
summary['Execution profile'] = workflow.profile

log.info summary.collect { k,v -> "${k.padRight(18)}: $v" }.join("\n")
log.info "-\033[91m--------------------------------------------------\033[0m-"

// Import subworkflow
include { MMSEQS2 as PF } from './subworkflow/workflow_mmseqs2.nf'
include { MMSEQS2 as AF } from './subworkflow/workflow_mmseqs2.nf'
include { SSN           } from './subworkflow/workflow_ssn.nf'
include { ANALYSIS      } from './subworkflow/workflow_analysis.nf'
include { STRUCTURE     } from './subworkflow/workflow_structure.nf'

// Import modules
include { FastaProcessing      } from './modules/data_processing.nf'
include { AnnotationProcessing } from './modules/data_processing.nf'
include { CheckCsvFormat       } from './modules/check_file_format.nf'
include { CheckLabelFormat     } from './modules/check_file_format.nf'
include { CheckFastaFormat     } from './modules/check_file_format.nf'
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	RUN ALL WORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow {

	// Channel
	proteome = Channel.fromPath(params.fasta, checkIfExists: true)
	inflation = Channel.of(params.I.split(",")).distinct()
    //quarto_seqs_clst = Channel.fromPath("${projectDir}/bin/report_seqs_clst.qmd")

	// concaténation de tous les fichiers FASTA
	sequences = proteome.collectFile(name: "${workDir}/concatenated_files/all_sequences.fasta")

	CheckFastaFormat(sequences)
	FastaProcessing(CheckFastaFormat.out.sequences_verif)
	all_sequences_rename = FastaProcessing.out.sequence_rename

	split_fasta = all_sequences_rename.splitFasta(by: 1000000, file: true)

	/* Function and Structure */

	if (params.scan_pfam == true || params.annotation == null) {
		PF(all_sequences_rename, params.pfam_name, "run_pfam")
	}

	/* Annotation */

	if (params.annotation != null) {
		CheckCsvFormat(Channel.fromPath(params.annotation, checkIfExists: true) )
		samplesheet = CheckCsvFormat.out.csv_verif
		samplesheet = samplesheet.splitCsv(header:true) \
				| map { row-> tuple(row.annotation, file(row.file)) }
		CheckLabelFormat(samplesheet)
        AnnotationProcessing(all_sequences_rename, CheckLabelFormat.out.label_annotation)
	}

	/* Combine annotation + channel */

	if (params.scan_pfam == true && params.annotation != null) {
		label_infos = PF.out.label.concat(AnnotationProcessing.out.label_annotation)
	}
	else if (params.scan_pfam == false && params.annotation != null) {
		label_infos = AnnotationProcessing.out.label_annotation
	}
	else if (params.scan_pfam == true && params.annotation == null) {
		label_infos = PF.out.label
	}

	/* Sequence Similarity Sequence */

	SSN(all_sequences_rename, split_fasta, params.alignment_file, inflation)

	AF(all_sequences_rename, params.alphafold_name, "run_alphafold")
	//all_labels = AF.out.label.concat(label_infos).collectFile(name: "${workDir}/concatenated_files/labels.tsv")
	//tuple_alphafold = AlphafoldNetwork(network, params.uniprot, AlphafoldAlignment.out.alphafold_aln_filter)
	//all_labels.view()
	
	STRUCTURE(SSN.out.network, AF.out.label, all_sequences_rename)
	all_labels = STRUCTURE.out.labels_alphafold.concat(label_infos).collectFile(name: "${workDir}/concatenated_files/labels.tsv")

	ANALYSIS(all_sequences_rename, SSN.out.network, all_labels, STRUCTURE.out.tuple_alphafold, SSN.out.tuple_edge)
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow.onComplete {

	println "- Workflow info: LAGOON-MCL workflow completed successfully -"

	log.info ABIHeader()
}

workflow.onError = {

    println "- Workflow info: LAGOON-MCL workflow completed with errors -"

	log.info ABIHeader()
}

def ABIHeader() {
	return """ 
		============================================
				╔═══╗ ╔═══╗   ╔═╗
				║╔═╗║ ║╔═╗║   ╚═╝
				║╚═╝║ ║╚═╝╚═╗ ╔═╗
				╠═══╣ ║ ╔═╗ ║ ║ ║
				║   ║ ║ ╚═╝ ║ ║ ║
				╩   ╩ ╚═════╝ ╚═╝
				(https://bioinfo.mnhn.fr/abi/)
		============================================
	"""
	.stripIndent()
}
