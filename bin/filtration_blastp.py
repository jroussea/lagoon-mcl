#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Nov 20 19:45:57 2024

@author: jroussea
@date: 2025-02-28
@version: 1.0
@contact: https://github.com/jroussea/lagoon-mcl/discussions
@license: MIT License
@description: Ce script permet de ne sélection qu'un seul alignement par pour chaque pair de séquence.
"""


from argparse import ArgumentParser


def get_args():
    """
    Parse arguments
    """
    parser = ArgumentParser(description="")
    
    parser.add_argument("-a", "--alignment", type = str,
                        help = "Network obtained after clustering with MCL", 
                        required = True)

    return parser.parse_args()


def main(args):
    """
    L'objectif de ce script est de limiter l'usage de la mémoire RAM

    Parameters
    ----------
    args : TYPE
        DESCRIPTION.

    Returns
    -------
    None.

    """
    d_sequence = hash_table_sequence(args.alignment)

    d_evalue = alignments_selection(args.alignment, d_sequence)

    d_position = hash_table_position(d_evalue)

    export_alignments(args.alignment, "diamond_alignment.filter.tsv", d_position)


def hash_table_sequence(diamond):
    """
    Création d'un dictionnaire qui attribuet un identifiant (0, 1, 2, 3, ...) à 
    chaque séqunece présente dans l'alignement BLASTp

    Parameters
    ----------
    diamond : STR
        Alignement BLASTp.

    Returns
    -------
    d_sequence : DICT
        Dictionnaire qui attribue un identifiant à chaque séquence.
        Clé: identifiant des séquence dans l'alignement BLASTp
        Value : identifiant (0, 1, 2, 3, 4, ...)

    """
    d_sequence = dict()

    count = 0

    with open(diamond, 'r') as f_alignment:
        
        #for position, alignment in enumerate(f_alignment):
        #    alignment = alignment.strip()
        #    l_alignment = alignment.split('\t')

        for alignment in f_alignment:
            l_alignment = alignment.rstrip("\n").split('\t')

            if l_alignment[0] not in d_sequence:
                count += 1
                d_sequence[l_alignment[0]] = count
            if l_alignment[4] not in d_sequence:
                count += 1
                d_sequence[l_alignment[4]] = count
    return d_sequence 


def hash_table_position(d_evalue):
    """
    

    Parameters
    ----------
    d_evalue : DICT
        dictionnaire des alignements sélection 
        Clé : identifiant des séquences query et targe présent dans le dictionnaire d_sequence.
                id_query-id_target (l'utilisation d'un identifiant en lieu et place de l'identifiant complet de la séquence
                                    permet de limiter l'usage de la mémoire RAM)
        Veleur : tuple position 1 : position de le fichier d'alignement compris entre 0 et nombre d'alignement - 1
                       position 2 : evalue

    Returns
    -------
    d_position : DICT
        Position (numéro de ligne) des alignements sélectionner dans le fichier 
        d'alignement BLASTp
        Clé : numéro de la ligne (positon)
        valeur : alignement id_query-id_target
            id_query et id_target sont présent dans le dictionnaire d_sequence

    """
    d_position = dict()

    for key in d_evalue:
        d_position[d_evalue[key][0]] = key
    return d_position


def alignments_selection(diamond, d_sequence):
    """
    dictionnaire des alignements sélectionner en fonction de la evalue
    s'il a plusieurs alignement qui inclu les meme séquences query et target alors
    cette fonction sélectionne l'alignement avec la meilleur evalue pour n'en garder q'un seul

    Parameters
    ----------
    diamond : STR
        Fichier TSV obtenue avec BLASTp.
    d_sequence : DICT
        Dictionnaire qui attribue un identifiant à chaque séquence.
        Clé: identifiant des séquence dans l'alignement BLASTp.
        Value : identifiant (0, 1, 2, 3, 4, ...)

    Returns
    -------
    d_evalue : DICT
        dictionnaire des alignements sélection 
        Clé : identifiant des séquences query et targe présent dans le dictionnaire d_sequence.
                id_query-id_target (l'utilisation d'un identifiant en lieu et place de l'identifiant complet de la séquence
                                    permet de limiter l'usage de la mémoire RAM)
        Veleur : tuple position 1 : position de le fichier d'alignement compris entre 0 et nombre d'alignement - 1
                       position 2 : evalue

    """
    d_evalue = dict()

    with open(diamond, 'r') as f_alignment:
        for position, alignment in enumerate(f_alignment):
            alignment = alignment.strip()
            l_alignment = alignment.split('\t')
            s_alignment_1 = str(d_sequence[l_alignment[0]]) + "-" + str(d_sequence[l_alignment[4]])
            s_alignment_2 = str(d_sequence[l_alignment[4]]) + "-" + str(d_sequence[l_alignment[0]])
            if str(d_sequence[l_alignment[0]]) != str(d_sequence[l_alignment[4]]):
                if s_alignment_1 in d_evalue and s_alignment_2 not in d_evalue:
                    if float(l_alignment[12]) < float(d_evalue[s_alignment_1][1]):
                        d_evalue[s_alignment_1] = (position, l_alignment[12])
                elif s_alignment_1 not in d_evalue and s_alignment_2 in d_evalue:
                    if float(l_alignment[12]) < float(d_evalue[s_alignment_2][1]):
                        d_evalue[s_alignment_2] = (position, l_alignment[12])
                elif s_alignment_1 not in d_evalue and s_alignment_2 not in d_evalue:
                    d_evalue[s_alignment_1] = (position, l_alignment[12])

    return d_evalue


def export_alignments(diamond, output, d_position):
    """
    Export des alignements sélectionner dans un nouveau fichier TSV

    Parameters
    ----------
    diamond : STR
        Fichier TSV obtenue avec BLASTp.
    output : STR
        Nom du fichier de sortie.
    d_position : DICT
        Position (numéro de ligne) des alignements sélectionner dans le fichier 
        d'alignement BLASTp
        Clé : numéro de la ligne (positon)
        valeur : alignement id_query-id_target
            id_query et id_target sont présent dans le dictionnaire d_sequence

    Returns
    -------
    None.

    """
    f_filter = open(output, 'w')
    
    with open(diamond, 'r') as f_alignment:
        for position, alignment in enumerate(f_alignment):
            if position in d_position:
                f_filter.write(alignment)
    
    f_filter.close()


if __name__ == '__main__':
    
    args = get_args()
    main(args)