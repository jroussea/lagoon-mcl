/*
* -------------------------------------------------
*  Nextflow config file for processes options
* -------------------------------------------------
* Defines general paths for input files and
* parameters for your own LAGOON-MCL analysis
*/

params {
    
    /*
    General parameters
    */
    // Analyzed project name

    projectName = "LAGOON-MCL"

    // input fasta
    fasta =  "$baseDir/tests/small/tr_files_test/*.fasta" 
    annotation = "$baseDir/tests/small/an_files_test"
    pep_colname = "peptides"

    columns_attributes = "database-identifiant,interproscan"

    // other
    concat_fasta = "all_sequences"

    // Output directory
    outdir = "$baseDir/results"

    // diamond database
    diamond_db = "reference" // database

    // diamond blastp option
    run_diamond = true
    
    alignment_file = ""
    
    column_query = 1
    column_subject = 2
    column_id = 3
    column_ov = 4
    column_ev = 12

    diamond = "diamond_alignment.tsv"
    sensitivity = "sensitive"
    matrix = "BLOSUM62"
    diamond_evalue = 0.001

    // diamond result
    filter = true
    identity = "60"
    overlap = "80"
    evalue = "1e-50"

    // network
    // MCL
    run_mcl = true
    I = "1.4,2"
    max_weight = 350 

    // general parameters used in iggraph and mcl
    min_cc_size = 1
}


/*
PLEASE DO NOT MODIFY THIS FILE (UNLESS YOU KNOW WHAT YOU DOING)
*/
