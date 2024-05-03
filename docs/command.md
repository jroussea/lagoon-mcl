# LAGOON-MCL

version 1.0.0

## Table of content

* [Presentation](index.md)
* [Intallation](installation.md)
* [Command line options](command.md)
* [Citing LAGOON-MCL](citation.md)
* [Contribution and Support](contact.md)

## General parameters

### Mandatory parameters

* `--fasta`

Path to fasta files. It is necessary to indicate the name of the FASTA file. If there are several files use `*.extension`. \
Example: `"$baseDir/tests/full/tr_files_test/*.fasta"`

* `--annotation`

Path to sequence annotation files. You should not specify the name of the file(s) but only the name of the folder containing the files. \
Exemple: `"$baseDir/tests/full/an_files_test"`

* `--pep_colname`

Name of the column containing the sequence names in the annotation file(s). \
Example: `"peptides"`

* `--columns_attributes`

Name of the columns that will be used to annotate the networks. \
Each column name must be separated by a `,`. If two columns are linked, for example the database column (contains the names of the databases: Pfam, CATH, ...) and the identifier (contains the identifiers specific to the databases) it is necessary to separate them by `-`. \
Example: `"database-identifiant,go"`

### Optional parameters

* `--projectName`

Name of the project \
Default: `LAGOON-MCL`

* `--outdir`

Path to the folder containing the results.
Default: `"$baseDir/results"`

* `--concat_fasta`

Name of the file that will contain all the fasta sequences.

* `--information`
Boolean: `true` or `false`. \
Specify `true` if you have a `TSV` file which contains information that applies to all sequences in a file.
If `true` then use parameters `--information_files` and `--information_attributes`. \
Default: `false`

* `--information_files`

Mandatory if `--information true`

Path to the `TSV` file containing general information about each `FASTA` file. One line in the `TSV` file corresponds to one `FASTA` file. \
Example: if you have 30 `FASTA` files containing the genomes of 30 different species (1 file = 1 species) then the `TSV` file will contain 30 lines. For example, each line can correspond to the taxonomy of each species. \
/!\ **WARNING 1** - the first column contains the `FASTA` file name (without the `.fasta` extension). /!\ \
/!\ **WARNING 2** - it is possible to specify only one `TSV` file with this option /!\

* `--information_attributes`

Mandatory if `--information true`

Cette option est identique à l'option `--columns_attributes`. Pour plus d'information, voir les information concernant [`--columns_attributes`](command.md#mandatory-parameters).

## Alignment parameters

### LAGOON-MCL parameters

* `--alignment_file`

Path to a file containing pairwise alignments, to be used if `--run_diamond false`. \
Example: `"$baseDir/tests/alignment/diamond_alignment_test.tsv"`. \
The file must be in `TSV` format (Tab-separated values). \
It is mandatory to specify the options: `--column_query`, `--column_subject`, `--column_id`, `--column_ov`, `--column_ev`. 

* `--query`

Position of the column in the alignment file containing the query sequences. \
Default: `1`

* `--subject`

Position of the column in the alignment file containing the subject sequences. \
Default: `2`

* `--evalue`

Position of the column in the alignment file containing the evalue of the alignment between the query and subject sequences. \
Default: `12`

### Diamond parameters

* `--diamond`

Name of the file containing the pairwise alignment from Diamond blastp. \
Default : `diamond_alignment.tsv`

* `--diamond_db`

Name of the database created with the `diamond makedb` command. \
Default: `reference`

* `--sensitivity`

Diamond sensitivity setting (`fast`, `mid-sensitive`, `more-sensitive`, `very-sensitive`, `sensitive`, `ultra-sensitive`). \
For more information, see the [Diamond documentation](https://github.com/bbuchfink/diamond/wiki/3.-Command-line-options#sensitivity-modes). \
Default: `sensitive`. 

* `--matrix`

Matrix used for alignment (`BLOSUM45`, `BLOSUM50`, `BLOSUM62`, `BLOSUM80`, `BLOSUM90`, `PAM250`, `PAM70`, `PAM30`). \
For more information, see the [Diamond documentation](https://github.com/bbuchfink/diamond/wiki/3.-Command-line-options#alignment-options). \
Default: `BLOSUM62`. 

* `--diamond_evalue`

Evalue used by `diamond blastp`. \ 
For more information, see the [Diamond documentation](https://github.com/bbuchfink/diamond/wiki/3.-Command-line-options#output-options). \
Dafault: `0.001`.

## Network parameters

* `--run_mcl`

Boolean: `true`or `false`. Running Markov CLustering algorithm. \
Default: `false`.

* `--I`

Inflation parameter for Markov CLustering algorithm. For more information, see the [MCL documentation](https://micans.org/mcl/). \
It is possible to specify several inflation parameter. In this case it separates them by `,`. \
Default: `1.4`

* `--max_weight`

Maximum weight for edges. This allows you to avoid having stops with infinite weight. Because the values are transformed into negative log 10. \
Dafault: `350`