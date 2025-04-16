#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Nov 20 19:45:57 2024

@author: jroussea
@date: 2025-02-28
@version: 1.0
@contact: https://github.com/jroussea/lagoon-mcl/discussions
@license: MIT License
@description: This script allows only one alignment to be selected for each pair of sequences.
"""


from argparse import ArgumentParser


def main(args):
    """

    Parameters
    ----------
    args.alignment : TSV
        Alignments files

    """
    d_sequence = hash_table_sequence(args.alignment)

    d_evalue = alignments_selection(args.alignment, d_sequence)

    d_position = hash_table_position(d_evalue)

    export_alignments(args.alignment, "diamond_alignments.filter.tsv", d_position)


def get_args():
    """
    Parse arguments
    """
    parser = ArgumentParser(description="This script allows only one alignment to be selected for each pair of sequences.")
    
    parser.add_argument("-a", "--alignment", type = str,
                        help = "Alignments files", 
                        required = True)

    return parser.parse_args()


def hash_table_sequence(diamond):
    """
    Creation of a dictionary that assigns an identifier (0, 1, 2, 3, ...) 
    to each each sequence in the BLASTp alignment

    Parameters
    ----------
    diamond : TSV
        BLESTp alignments

    Returns
    -------
    d_sequence : DICT
        Dictionary that assigns an identifier to each sequence.
            Key: sequence name in BLASTp alignment
            Value: identifier (0, 1, 2, 3, 4, ...)

    """
    d_sequence = dict()

    count = 0

    with open(diamond, 'r') as f_alignment:
        for row in f_alignment:
            l_row = row.rstrip("\n").split('\t')

            if l_row[0] not in d_sequence:
                count += 1
                d_sequence[l_row[0]] = count
            if l_row[4] not in d_sequence:
                count += 1
                d_sequence[l_row[4]] = count
    return d_sequence 


def hash_table_position(d_evalue):
    """
    Dictionary of selected alignment positions

    Parameters
    ----------
    d_evalue : DICT
        dictionary of alignments selected 
            Key: identifiers of the selected sequence pair
            Value: TUPLE
                position 1: position of the alignment file
                position 2: evalue

    Returns
    -------
    d_position : DICT
        Position of selected alignments
        Key: line number in alignment file
        Value: sequence pair ID

    """
    d_position = dict()

    for key in d_evalue:
        d_position[d_evalue[key][0]] = key
    return d_position


def alignments_selection(diamond, d_sequence):
    """
    For each pair of sequences, select the alignment with the best evalue

    Parameters
    ----------
    diamond : TSV
        BLASTP fil
    d_sequence : DICT
        Dictionary that assigns an identifier to each sequence.
            Key: sequence name in BLASTp alignment
            Value: identifier (0, 1, 2, 3, 4, ...)

    Returns
    -------
    d_evalue : DICT
        dictionary of alignments selected 
            Key: identifiers of the selected sequence pair
            Value: TUPLE
                position 1: position of the alignment file
                position 2: evalue

    """
    d_evalue = dict()

    with open(diamond, 'r') as f_alignment:
        for position, row in enumerate(f_alignment):
            l_row = row.strip().split('\t')
            s_alignment_1 = str(d_sequence[l_row[0]]) + "-" + str(d_sequence[l_row[4]])
            s_alignment_2 = str(d_sequence[l_row[4]]) + "-" + str(d_sequence[l_row[0]])
            if str(d_sequence[l_row[0]]) != str(d_sequence[l_row[4]]):
                if s_alignment_1 in d_evalue and s_alignment_2 not in d_evalue:
                    if float(l_row[12]) < float(d_evalue[s_alignment_1][1]):
                        d_evalue[s_alignment_1] = (position, l_row[12])
                elif s_alignment_1 not in d_evalue and s_alignment_2 in d_evalue:
                    if float(l_row[12]) < float(d_evalue[s_alignment_2][1]):
                        d_evalue[s_alignment_2] = (position, l_row[12])
                elif s_alignment_1 not in d_evalue and s_alignment_2 not in d_evalue:
                    d_evalue[s_alignment_1] = (position, l_row[12])

    return d_evalue


def export_alignments(diamond, output, d_position):
    """
    Export des alignements sélectionner dans un nouveau fichier TSV

    Parameters
    ----------
    diamond : STR
        BLASTp file
    output : TSV
        Output file
    d_position : DICT
        Position of selected alignments
        Key: line number in alignment file
        Value: sequence pair ID

    Returns
    -------
    None.

    """
    f_filter = open(output, 'w')
    
    with open(diamond, 'r') as f_alignment:
        for position, row in enumerate(f_alignment):
            if position in d_position:
                f_filter.write(row)
    
    f_filter.close()


if __name__ == '__main__':
    
    args = get_args()
    main(args)