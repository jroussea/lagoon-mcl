#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Feb 19 10:39:05 2025

@author: jroussea
@date: 2025-02-28
@version: 1.0
@contact: https://github.com/jroussea/lagoon-mcl/discussions
@license: MIT License
@description: This script selects a single AlphaFold alignment per sequence
"""


from argparse import ArgumentParser


def main(args):
    """

    Parameters
    ----------
    args.alignments : TSV
        TSV file containing sequence alignments against the AlphaFold Cluster database.
    """
    # d_selection = alignments_selection(args.alignments)
    # write_alphafold_alignments(d_selection)
    
    # alignments = "pouic.m8"
    # alphafold_db = "alphafold_clusters_database_data.tsv"

    d_selection, d_alphafold = alignments_selection(args.alignments)
    write_alphafold_alignments(d_selection)
    d_af_db = alphafold_clusters(args.alphafold_db)
    write_annotations_files(d_alphafold, d_af_db)



def get_args():
    """
    Parse arguments

    """
    parser = ArgumentParser(description="This script selects a single AlphaFold alignment per sequence")
    
    parser.add_argument("-a", "--alignments", type = str,
                        help = "TSV file containing sequence alignments against the AlphaFold Cluster database.", 
                        required = True)
    
    parser.add_argument("-af", "--alphafold_db", type = str,
                        help = "", 
                        required = True)
    
    return parser.parse_args()


def dico_key_value(d_selection, l_alignment, key):
    """
    Update selected alignments for each sequence

    Parameters
    ----------
    d_selection : DICT
        Dictionary containing the alignments selected for each sequence.
    l_alignment : LIST
        Alignment list under analysis.
    disparity_index : FLOAT
        Disparity index
    coverage_index : FLOAT
        Coverage index

    Returns
    -------
    d_selection : DICT
        Dictionary containing the alignments selected for each modified sequence.

    """
    d_selection[key] = {
        "query": l_alignment[0],
        "target": l_alignment[1],
        "fident": (l_alignment[2]),
        "alnlen": l_alignment[3],
        "mismatch": l_alignment[4],
        "gapopen": l_alignment[5],
        "qstart": l_alignment[6],
        "qend": l_alignment[7],
        "qlen": l_alignment[8],
        "tstart": l_alignment[9],
        "tend": l_alignment[10],
        "tlen": l_alignment[11],
        "evalue": l_alignment[12],
        "bits": l_alignment[13]}
    
    return d_selection


def alignments_selection(alignments):
    """
    Selection of an alignment by sequence.
        
    Parameters
    ----------
    alignments : STR
        TSV file containing sequence alignments against the AlphaFold Cluster database.

    Returns
    -------
    d_selection : DICT
        Dictionary containing the alignments that best represent the sequences.

    """
    d_selection = dict()
    d_alphafold = dict()
    count = 0
    with open(alignments, "r") as f_alphafold:
        
        for row in f_alphafold:

            l_row = row.rstrip("\n").split('\t')

            cov_query = (int(l_row[7]) - int(l_row[6]) + 1) / int(l_row[8])
            cov_query_pourc = cov_query * 100
            
            cov_subject = (int(l_row[10]) - int(l_row[9]) + 1) / int(l_row[11])
            cov_subject_pourc = cov_subject * 100

            if cov_query_pourc >= 80 and cov_subject_pourc >= 80 and float(l_row[2]) >= 0.3:

                d_selection = dico_key_value(d_selection, l_row, count)
                
                if l_row[0] not in d_alphafold:
                    d_alphafold[l_row[0]] = {l_row[1][8:-3]}
                else:
                    d_alphafold[l_row[0]].add(l_row[1][8:-3])
                
                count += 1

    return d_selection, d_alphafold


def write_alphafold_alignments(d_selection):
    """
    Write the file containing the selected alignments.
    
    Parameters
    ----------
    d_selection : DICT
        Dictionary containing the alignments selected for each sequence.

    Returns
    -------
    None.

    """
    f_aln_selection = open("mmseqs2_alpahfold_clusters_alignments.selection.tsv", "w")

    for key, value in d_selection.items():

        l_alignement = [
            str(value["query"]),
            str(value["target"]),
            str(value["fident"]),
            str(value["alnlen"]),
            str(value["mismatch"]),
            str(value["gapopen"]),
            str(value["qstart"]),
            str(value["qend"]),
            str(value["qlen"]),
            str(value["tstart"]),
            str(value["tend"]),
            str(value["tlen"]),
            str(value["evalue"]),
            str(value["bits"])]

        f_aln_selection.write('\t'.join(l_alignement) + '\n')

    f_aln_selection.close()

def alphafold_clusters(filename):
    
    d_af_db = dict()

    with open(filename, "r") as file:
        
        for position, row in enumerate(file):
            
            l_row = row.rstrip("\n").split('\t')
            
            d_af_db[l_row[0]] = {"clst": l_row[1], "pfamID": l_row[2]}

    return d_af_db


def write_annotations_files(d_alphafold, d_af_db):
    
    output_sequences = open("alphafold_sequences.tsv", "w")
    output_clusters = open("alphafold_clusters.tsv", "w")
    output_pfam = open("alphafold_pfam.tsv", "w")
        
    output_sequences.write("\t".join(["sequence_id", "label"]))
    output_clusters.write("\t".join(["sequence_id", "label"]))
    output_pfam.write("\t".join(["sequence_id", "label"]))

    for key, value in d_alphafold.items():
        
        sequences = ";".join(value)
        s_clusters = set()
        s_pfam = set()
        
        
        for id_seq in value:
            s_clusters.add(d_af_db[id_seq]["clst"])
            if d_af_db[id_seq]["pfamID"] != "None":
                s_pfam.add(d_af_db[id_seq]["pfamID"])

        clusters = ";".join(s_clusters)
        pfam = ";".join(s_pfam)

        output_sequences.write('\t'.join([key, sequences]) + '\n')
        output_clusters.write('\t'.join([key, clusters]) + '\n')
        output_pfam.write('\t'.join([key, pfam]) + '\n')

    output_pfam.close()
    output_clusters.close()
    output_sequences.close()


if __name__ == '__main__':
    args = get_args()
    main(args)