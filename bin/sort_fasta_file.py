#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri May 30 12:16:41 2025

@author: jrousseau
"""

from argparse import ArgumentParser


def main(args):
    sequences = read_fasta_file(args.input)
    write_fasta_file(sequences, args.output)
    

def get_args():
    """
    Parse arguments

    """
    parser = ArgumentParser(
        description="")

    parser.add_argument("-i", "--input", type=str,
                        help="",
                        required=True)

    parser.add_argument("-o", "--output", type=str,
                        help="",
                        required=True)

    return parser.parse_args()


def read_fasta_file(fasta_file):
    sequences = {}
    header = None
    seq_lines = []
    with open(fasta_file, 'r') as f:
        for line in f:
            line = line.rstrip()
            if line.startswith(">"):
                if header:
                    sequences[header] = "".join(seq_lines)
                header = line
                seq_lines = []
            else:
                seq_lines.append(line)
        if header:
            sequences[header] = "".join(seq_lines)
    return sequences


def write_fasta_file(sequences, output_file):
    with open(output_file, 'w') as f:
        for header in sorted(sequences.keys()):
            f.write(header + "\n")
            # On peut écrire la séquence en lignes de 60 caractères par exemple
            seq = sequences[header]
            for i in range(0, len(seq), 60):
                f.write(seq[i:i+60] + "\n")


if __name__ == '__main__':
    args = get_args()
    main(args)