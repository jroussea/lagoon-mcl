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
    d_selection = alignments_selection(args.alignments)
    write_alphafold_alignments(d_selection)


def get_args():
    """
    Parse arguments

    """
    parser = ArgumentParser(description="This script selects a single AlphaFold alignment per sequence")
    
    parser.add_argument("-a", "--alignments", type = str,
                        help = "TSV file containing sequence alignments against the AlphaFold Cluster database.", 
                        required = True)
    
    return parser.parse_args()


def dico_key_value(d_selection, l_alignment, coverage_index, disparity_index):
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
    d_selection[l_alignment[0]] = {
        "target": l_alignment[1],
        "fident": l_alignment[2],
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
        "bits": l_alignment[13],
        "coverage_index": coverage_index,
        "disparity_index": abs(disparity_index)
        }
    
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
    
    with open(alignments, "r") as f_alphafold:
        
        for row in f_alphafold:

            l_row = row.rstrip("\n").split('\t')
    
            cov_query = (float(l_row[7]) - float(l_row[6]) + 1) / float(l_row[8])
            cov_target = (float(l_row[10]) - float(l_row[9]) + 1) / float(l_row[11])
            disparity_index = abs(cov_query - cov_target)
            coverage_index = (cov_query + cov_target)/2

            if l_row[0] not in d_selection.keys():
                d_selection = dico_key_value(d_selection, l_row, coverage_index, disparity_index)
    
            elif l_row[0] in d_selection.keys():

                
                if coverage_index > d_selection[l_row[0]]["coverage_index"] and \
                    disparity_index < d_selection[l_row[0]]["disparity_index"] and \
                        (l_row[2]) >= d_selection[l_row[0]]["fident"] and \
                            l_row[8] >= d_selection[l_row[0]]["qlen"]:

                    d_selection = dico_key_value(d_selection, l_row, coverage_index, disparity_index)
    
                elif coverage_index >= d_selection[l_row[0]]["coverage_index"] and \
                    disparity_index <= d_selection[l_row[0]]["disparity_index"] and \
                        l_row[2] >= d_selection[l_row[0]]["fident"] and \
                            l_row[8] >= d_selection[l_row[0]]["qlen"]:

                    d_selection = dico_key_value(d_selection, l_row, coverage_index, disparity_index)
                    
    return d_selection


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
            str(key),
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
            str(value["bits"]),
            str(value["coverage_index"]),
            str(value["disparity_index"])
            ]

        f_aln_selection.write('\t'.join(l_alignement) + '\n')

    f_aln_selection.close()


if __name__ == '__main__':
    args = get_args()
    main(args)