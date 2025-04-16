#!/usr/bin/env nextflow

// Enable modules
nextflow.enable.dsl = 2

def helpMessage() {
	log.info ABIHeader()
	log.info """
	
	LAGOON-MCL

	For more information, see the documentation: https://github.com/jroussea/lagoon-mcl
	=============================================================================================

	--help

	--max_cpus <int>         [optional]  : Maximum number of CPUs that can be used by LAGOON-MCL
		[default: 200]
	--max_memory <int.GB>    [optional]  : Maximum amount of RAM that can be used by LAGOON-MCL
		[default: 750.GB]
	--max_time <int.h>       [optional]  : Maximum runtime for LAGOON-MCL
		[default: 336.h]

	--projectName <str>      [optional]  : Project name, used to name the folder in the working directory
		[default: lagoon-mcl]
	--fasta <file>           [mandatory] : One or more in fasta format containing protein sequences
	--outdir <path>          [mandatory] : Output folder

	--scan_pfam <bool>       [optional]  : true: sequences are aligned against the Pfam database
		[dafault: true]                    false: sequences are not aligned against the Pfam database
	--pfam_path <path>       [optional]  : (si scan_pfam true), chemin du répertoire contenant la banque de données Pfam (doit avoir été construit avec MMseqs2)
		[default: database/pfamDB]
	--pfam_name <str>        [optional]  : (if scan_pfam true), name of Pfam database
		[default: pfamDB]

	--alphafold_path <path>  [mandatory] : Path of directory containing AlphaFold clusters database (must have been built with MMseqs2)
		[default: database/alphafoldDB]
	--alphafold_name <str>   [mandatory] : AlphaFold clusters database name
		[default: alphafoldDB]
	--uniprot <file>         [mandatory] : JSON file with : - UniProt identifiers (correspond to identifiers in the AlphaFold clusters database)
		[default: database/uniprot_function.json]           - As well as Pfam annotations linked to UniProt identifiers and available in the InterPro database.

	--annotation <file>      [optional]  : CSV file with path to sequence annotation files and annotation names

	--alignment_file <file>  [optional]  : Sequence alignment file (pairwise alignment) in .m8 format (e.g. BLASTp output) 
	--sensitivity <str>      [optional]  : Diamond BLASTp sensitivity 
		[default: very-sensitive]
	--matrix <str>           [optional]  : Similarity matrix
		[default: BLOSUM62]
	--diamond_evalue <flaot> [optional]  : E-value
		[default: 0.001]

	--I <list>               [optional]  : List of parameters used by LAGOON-MCL
		[default: "1.4,2,4"]
	--max_weight <float>     [optional]  : For MCL, maximum weight of an edge
		[default: 200]
	--cluster_size <int>     [optional]  : Minimum cluster size
		[default: 2]

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
log.info ABIHeader()
def summary = [:]
if (workflow.revision)
summary['Pipeline Release']  = workflow.revision
summary['Run Name']          = workflow.runName
summary['Project Name']      = params.projectName
summary['Output dir']        = params.outdir
summary['Launch dir']        = workflow.launchDir
summary['Working dir']       = workflow.workDir
summary['Script dir']        = workflow.projectDir
summary['User']              = workflow.userName
summary['Execution profile'] = workflow.profile

log.info summary.collect { k,v -> "${k.padRight(18)}: $v" }.join("\n")
log.info "-\033[91m--------------------------------------------------\033[0m-"

// Import subworkflow
include { FUNCTION_SEARCHES        } from './subworkflow/function_searches.nf'
include { STRUCTURE_SEARCHES       } from './subworkflow/structure_searches.nf'
include { SSN_AND_GRAPH_CLUSTERING } from './subworkflow/ssn_and_graph_clustering.nf'
include { DATA_ANALYSIS            } from './subworkflow/data_analysis.nf'
// Import modules
include { FASTA_PROCESSING         } from './modules/data_processing.nf'
include { ANNOTATIONS_PROCESSING   } from './modules/data_processing.nf'
include { CHECKS_FASTA             } from './modules/check_file_format.nf'
include { CHECK_CSV                } from './modules/check_file_format.nf'
include { CHECKS_TSV               } from './modules/check_file_format.nf'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	RUN ALL WORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow {

	// Channel
	proteome = Channel.fromPath(params.fasta, checkIfExists: true)
	inflation = Channel.of(params.I.split(",")).distinct()

	sequences = proteome.collectFile(name: "${workDir}/concatenated_files/all_fasta_sequences_in_one_file.fasta")

	/* Checks fasta files and fasta processing */
	CHECKS_FASTA(sequences)
	FASTA_PROCESSING(CHECKS_FASTA.out.sequences_checking)
	sequences_renamed = FASTA_PROCESSING.out.sequences_renamed

	split_fasta_files = sequences_renamed.splitFasta(by: 1000000, file: true)

	/* Function searches */
	if (params.scan_pfam == true || params.annotation == null) {
		FUNCTION_SEARCHES(sequences_renamed, params.pfam_name)
	}

	/* Check CSV file, check TSV files and annotation processing */
	if (params.annotation != null) {
		CHECK_CSV(Channel.fromPath(params.annotation, checkIfExists: true))
		samplesheet = CHECK_CSV.out.csv_checking
		samplesheet = samplesheet.splitCsv(header:true) \
				| map { row-> tuple(row.annotation, file(row.file)) }
		CHECKS_TSV(samplesheet)
        ANNOTATIONS_PROCESSING(sequences_renamed, CHECKS_TSV.out.tsv_checking)
	}

	/* Combine annotations */
	if (params.scan_pfam == true && params.annotation != null) {
		all_annotations = FUNCTION_SEARCHES.out.pfam_files.concat(ANNOTATIONS_PROCESSING.out.annotations_files)
	}
	else if (params.scan_pfam == false && params.annotation != null) {
		all_annotations = ANNOTATIONS_PROCESSING.out.annotations_files
	}
	else if (params.scan_pfam == true && params.annotation == null) {
		all_annotations = FUNCTION_SEARCHES.out.pfam_files
	}

	/* Sequence Similarity Sequence and graph clustering */
	SSN_AND_GRAPH_CLUSTERING(sequences_renamed, split_fasta_files, params.alignment_file, inflation)

	/* Structure searches */
	STRUCTURE_SEARCHES(split_fasta_files, sequences_renamed, params.alphafold_name, SSN_AND_GRAPH_CLUSTERING.out.network)
	all_annotations_and_structures = STRUCTURE_SEARCHES.out.alphafold_annotations.concat(all_annotations).collectFile(name: "${workDir}/concatenated_files/all_sequence_annotations.tsv")

	/* Data analysis */
	DATA_ANALYSIS(sequences_renamed, SSN_AND_GRAPH_CLUSTERING.out.network, all_annotations_and_structures, SSN_AND_GRAPH_CLUSTERING.out.tuple_network_edges)
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow.onComplete {
    c_green = params.monochrome_logs ? '' : "\033[0;32m";
    c_purple = params.monochrome_logs ? '' : "\033[0;35m";
    c_red = params.monochrome_logs ? '' : "\033[0;31m";
    c_reset = params.monochrome_logs ? '' : "\033[0m";
    
	def msg = """
	-${c_red}--------------------------------------------------${c_reset}-
	Pipeline execution summary
	---------------------------
	Completed at : ${workflow.complete}
	Duration     : ${workflow.duration}
	Success      : ${workflow.success}
	workDir      : ${workflow.workDir}
	exit status  : ${workflow.exitStatus}
	-${c_red}--------------------------------------------------${c_reset}-
    """.stripIndent()
    println(msg)
	
	if (workflow.success) {
        log.info "-${c_purple}[Workflow info]${c_green} LAGOON-MCL workflow completed successfully${c_reset}-"
	} else {
        log.info "-${c_purple}[Workflow info]${c_red} LAGOON-MCL workflow completed with errors${c_reset}-"
    }
}

def ABIHeader() {
    // Log colors ANSI codes
    c_red = params.monochrome_logs ? '' : "\033[0;91m";
    c_blue = params.monochrome_logs ? '' : "\033[1;94m";
    c_reset = params.monochrome_logs ? '' : "\033[0m";
    c_yellow = params.monochrome_logs ? '' : "\033[1;93m";
    c_Ipurple = params.monochrome_logs ? '' : "\033[0;95m" ;

    return """    -${c_red}--------------------------------------------------${c_reset}-

    ${c_blue}  ╔═══╗╔══╗ ╔═╗    ${c_blue}
    ${c_blue}  ║╔═╗║║╔╗║ ╠═╣    ${c_blue}
    ${c_blue}  ║╚═╝║║╚╝╚╗║ ║    ${c_blue}
    ${c_blue}  ╠═══╣║╔═╗║║ ║    ${c_blue}
    ${c_blue}  ║   ║║╚═╝║║ ║    ${c_blue}
    ${c_blue}  ╩   ╩╚═══╝╚═╝    ${c_blue}
    ${c_yellow}  LAGOON-MCL workflow (version ${workflow.manifest.version})${c_reset}
                                            ${c_reset}
    ${c_Ipurple}  Homepage: ${workflow.manifest.homePage}${c_reset}
    -${c_red}--------------------------------------------------${c_reset}-
    """.stripIndent()

}