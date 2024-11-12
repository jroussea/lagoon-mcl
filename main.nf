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
include { PFAM   } from './subworkflow/workflow_pfam.nf'
include { SSN    } from './subworkflow/workflow_ssn.nf'
include { REPORT } from './subworkflow/workflow_report.nf'

// Import modules
include { PreparationFasta } from './modules/preparation.nf'
include { PreparationAnnot } from './modules/preparation.nf'

// Channel
proteome = Channel.fromPath(params.fasta, checkIfExists: true)
inflation = Channel.of(params.I.split(",")).distinct()

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	RUN ALL WORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow {

	// concaténation de tous les fichiers FASTA
	all_sequences = proteome.collectFile(name: "${params.outdir}/lagoon-mcl_output/diamond/all_sequences.fasta")

	PreparationFasta(all_sequences)
	all_sequences_rename = PreparationFasta.out.sequence_rename

	split_fasta = all_sequences_rename.splitFasta(by: 1000000, file: true)

	/* Pfam */

    if (params.scan_pfam == true) {
		PFAM(split_fasta)
		label_pfam = PFAM.out.label_pfam
	}

	/* Annotation */

	if (params.annotation_files != null) {
		annotation = Channel.fromPath(params.annotation_files, checkIfExists: true)
        PreparationAnnot(annotation)
		label_annotation = PreparationAnnot.out.label_annotation
	}

	/* Create channel */

	if (params.scan_pfam == true && params.annotation_files != null) {
		label_network = label_pfam.concat(label_annotation).collect()
	}
	else if (params.scan_pfam == false && params.annotation_files != null) {
		label_network = label_annotation.collect()
	}
	else if (params.scan_pfam == true && params.annotation_files == null) {
		label_network = label_pfam.collect()
	}

	/* Sequence Similarity Sequence */

	SSN(all_sequences_rename, split_fasta, params.alignment_file, inflation)
	tuple_network = SSN.out.tuple_network
	diamond_ssn = SSN.out.diamond_ssn

	REPORT(all_sequences_rename, SSN.out.network, tuple_network, label_network)
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
		========================================
			  ╔═══╗ ╔═══╗   ╔═╗
			  ║╔═╗║ ║╔═╗║   ╚═╝
			  ║╚═╝║ ║╚═╝╚═╗ ╔═╗
			  ╠═══╣ ║ ╔═╗ ║ ║ ║
			  ║   ║ ║ ╚═╝ ║ ║ ║
			  ╩   ╩ ╚═════╝ ╚═╝
	              (https://bioinfo.mnhn.fr/abi/)
		========================================
	"""
	.stripIndent()
}
