#!/usr/bin/env nextflow

// Enable modules
nextflow.enable.dsl = 2

def helpMessage() {
	log.info ABIHeader()
	log.info """
	
	LAGOON-MCL

	For more information, see the documentation: https://lagoon-mcl-docs.readthedocs.io/en/latest
	=============================================================================================

	/* Profiles */
		-profile conda or mamba or singularity

	/* General parameters */
		
		--help                    <bool>  true or false. Affiche cette aide

		--max_cpus                <int>   cpus max qui peut être alloué au workflow (defaul: 15)
		--max_memory              <int>   mem max qui peut être alloué au workflow (defaul: 60.GB)
		--max_time                <int    max time qui peut être alloué au workflow (default: 336.h)

   		--projectName             <str>   Name of the project 

		--fasta                   <path>  Path to fasta files
   		--outdir                  <path>  Path to the folder containing the results



	/* CATH / Gene3D */

		--scan_gene3d	<bool>
		--gene3d_aln	<path>



	/* ESM Metagenomic Atlas */

		--scan_esm_atlas	<bool>
		--esm_aln	<path>



	/* AlphaFolde Protein Structure Database */

		--scan_alphafold_db	<bool>
		--alphafold_aln	<path>



	/* Sequence Similarity Sequence */

		--run_diamond             <bool>  Allows you to specify whether you want to execute diamond (true or false)
		--diamond_db              <str>   Name of the database created with the diamond makedb command
		--alignment_file          <path>  Path to a file containing pairwise alignments (if --run_diamond false)
		--diamond                 <str>   Name of the file containing the pairwise alignment from Diamond blastp
		--sensitivity             <str>   Diamond sensitivity setting
		--matrix                  <str>   Matrix used for alignment
		--diamond_evalue          <float> Evalue used by diamond blastp

		--I                       <list>  Inflation parameter for MCL
		--max_weight              <int>   Maximum weight for edges



	/* Other attributes */

		--pep_colname             <str>   Name of the column containing the sequence names in the annotation file(s)

		--annotation_files		<path>
		--annotation_attrib      <list>  Name of the columns that will be used to annotate the networks

		--information_files       <paht>
		--information_attrib  <list>




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

include { GENE3D      } from './subworkflow/workflow_gene3d.nf'
include { PFAM        } from './subworkflow/workflow_pfam.nf'
include { ESMATLAS    } from './subworkflow/workflow_esmatlas.nf'
include { ALPHAFOLDDB } from './subworkflow/workflow_alphafolddb.nf'
include { SSN         } from './subworkflow/workflow_ssn.nf'
include { REPORT      } from './subworkflow/workflow_report.nf'

// Import modules
include { HomogeneityScore } from './modules/statistics.nf'
include { PreparationAnnot } from './modules/preparation.nf'

// préparation des paramètres
List<Number> list_inflation = Arrays.asList(params.I.split(","))

// Channel
proteome = Channel.fromPath(params.fasta, checkIfExists: true)
inflation = Channel.fromList(list_inflation)
quarto = Channel.fromPath("${projectDir}/bin/sequences_stats.qmd")
quarto_2 = Channel.fromPath("${projectDir}/bin/cluster_stats.qmd")

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	RUN ALL WORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow {

	// concaténation de tous les fichiers FASTA
	all_sequences = proteome.collectFile(name: "${params.outdir}/all_sequences.fasta")
	split_fasta = all_sequences.splitFasta(by: 1000, file: true)

	/* CATH / Gene3D */

	GENE3D(params.gene3d_aln, split_fasta)
	label_cath = GENE3D.out.label_cath

	/* Pfam */

	PFAM(params.pfam_aln, proteome)
	label_pfam = PFAM.out.label_pfam

	label_network = label_cath.concat(label_pfam).collect()

	/* ESM Metagenomic Atlas */

	if (params.esm_atlas == true) {
		ESMATLAS(params.esm_aln, proteome)
		esm_network = ESMATLAS.out.esm_label
	}

	/* AlphaFolde Protein Structure Database */
	
	if (params.alphafold == true) {
		ALPHAFOLDDB(params.alphafold_aln, proteome)
		alphafold_network = ALPHAFOLDDB.out.af_label
	}
	
	/* Other attributes */

	if (params.annotation_files != null) {
		annotation = Channel.fromPath(params.annotation_files, checkIfExists: true)
        PreparationAnnot(annotation)
		label_annotation = PreparationAnnot.out.label_annotation

		label_network = label_network.concat(label_annotation).collect()
	}

	/* Sequence Similarity Sequence */

	SSN(all_sequences, params.alignment_file, inflation)
	tuple_network = SSN.out.tuple_network
	diamond_ssn = SSN.out.diamond_ssn

	HomogeneityScore(label_network, tuple_network)
	tuple_hom_score = HomogeneityScore.out.tuple_hom_score
	tuple_hom_score = tuple_hom_score.groupTuple(by: 2)
	
	REPORT(quarto, quarto_2, all_sequences, diamond_ssn, label_network, SSN.out.network, tuple_hom_score)
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