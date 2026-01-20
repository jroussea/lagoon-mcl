# Toolkit

Ce dossier contient des scripts utilitaires pour le workflow bioinformatique Nextflow. 
Il inclut :

- `build_*.sh` : scripts principaux à exécuter pour effectuer certaines tâches.
- `bin/` : scripts internes utilisés par les `build_*.sh`.
- `scripts/` : scripts Python et Bash modulaires réutilisables pour des tâches spécifiques.

## Structure

toolkit/
│
├─ bin/                # Scripts internes utilisés par build_*.sh
├─ scripts/            # Scripts utilitaires réutilisables (Python, Bash)
├─ build_1.sh          # Script principal utilisant les scripts de bin/
└─ build_2.sh          # Script principal utilisant les scripts de bin/

## Prérequis

- Bash (>=4.0)
- Python (>=3.8)
- Packages Python utilisés dans `scripts/` (ex: pandas, numpy, ...)
- Permissions d'exécution pour `build_*.sh`

## Installation

ajout conda

```
chmod +x build_*.sh
```





# Tool-kit

This folder is a toolbox for preparing input files, building MMseqs databases for Pfam and AlphaFold clusters, and more.

## `scripts/`

- `convert_annotation_file.py`

- `extract_clusters_informations.py`

- `json_to_matrix.py`

- `run_slurm.sh`

## Database

LAGOON-MCL uses MMseqs2 to align sequences against the Pfam and AlphaFold cluster databases. For this, Pfam and AlphaFold databases must have been built using MMseqs2.

Two scritps are available.

To build the Pfam profile database
```bash
./build_pfam_db.sh
```
After using this script, it will be necessary to use the following parameters in LAGOON-MCL:
* `--pfamDB /path/to/database/pfamDB`: path to the database
* `--pfamDB_name pfamDB`: name of database

To build the AlphaFold clusters sequences database
```bash
./build_alphafold_db.sh 
```
After using this script, it will be necessary to use the following parameters in LAGOON-MCL:
* `--alphafolddDB /path/to/database/alphafoldDB`: path to the database
* `--alphafoldDB_name alphafoldDB`: name of database
* `--uniprot /path/to/database/uniprot_function.json`: pfam annotation linked to sequence identifiers in the AlphaFold clusters database available in the InterPro database

All data obtained with the two scripts are available in the folder: `database/`.