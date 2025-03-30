#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Feb 19 10:39:05 2025

@author: jroussea
@date: 2025-02-28
@version: 1.0
@contact: https://github.com/jroussea/lagoon-mcl/discussions
@license: MIT License
@description: Ce script sélectionne un seul alignement par séquence
"""


from argparse import ArgumentParser


def get_args():
    """
    Parse arguments
    
    """
    parser = ArgumentParser(description="Sélectionner un seul alignement par séquence en sortie de MMseqs2")
    
    parser.add_argument("-a", "--alignment", type = str,
                        help = "AlphaFold Alignment au format TSV (output of MMseqs2 alignment)", 
                        required = True)
    
    return parser.parse_args()


def main(args):
    """
    

    Parameters
    ----------
    args : TYPE
        DESCRIPTION.

    Returns
    -------
    None.

    """
    d_selection = alignment_selection(args.alignment)
    write_alphafold_alignment(d_selection)


def dico_key_value(d_selection, l_alignment, diff_cov):
    """
    Mise à jours des alignements sélectionné pour chaque séquence

    Parameters
    ----------
    d_selection : DICT
        Dictionnaire contenant les alignement sélectionné pour chaque séquences.
    l_alignment : LIST
        Liste de l'alignement en court d'analyse.
    diff_cov : FLOAT
        Valeur de la différence de couverture.

    Returns
    -------
    d_selection : DICT
        Dictionnaire contenant les alignement sélectionné pour chaque séquences modifié.

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
        "diff_cov": abs(diff_cov)
        }
    
    return d_selection


def alignment_selection(alphafold):
    """
    Séleciton d'un alignement par séquences.
    Plusieurs étape.
        Si la séquence est deja présente dans le dictionnaire d_selection : 
        - Étape 1 : remplacer l'alignement déjà  sélectionné si la différence de couverture
                        du nouvel alignement est plus strictiemennt inférieur
        - Étape 2 : remplace l'alignement déjà sélectionné 
                        - si la différence de couverture est inférieur ou égale à la précédente différence de couverture
                        - si le pourcentage d'identité est supérieur ou égale ou précédent alignement
                        - si la longeur de la séquence est supérieur ou égale à la précédente à la précédente séquence

    Parameters
    ----------
    alphafold : STR
        Fichier TSV contenant les alignements des séquences contre la base de données
            AlphaFold Cluster.

    Returns
    -------
    d_selection : DICT
        Dictionnaire contenant les alignements qui représente le mieux les séquences.

    """
    d_selection = dict()
    
    with open(alphafold, "r") as f_alphafold:
        
        for alignment in f_alphafold:

            l_alignment = alignment.rstrip("\n").split('\t')
    
            cov_query = (float(l_alignment[7]) - float(l_alignment[6]) + 1) / float(l_alignment[8]) * 100
            cov_target = (float(l_alignment[10]) - float(l_alignment[9]) + 1) / float(l_alignment[11]) * 100
            diff_cov = abs(cov_query - cov_target)
            
            if l_alignment[0] not in d_selection.keys():
                d_selection = dico_key_value(d_selection, l_alignment, diff_cov)
    
            elif l_alignment[0] in d_selection.keys():
                if diff_cov < d_selection[l_alignment[0]]["diff_cov"] and \
                    (l_alignment[2]) >= d_selection[l_alignment[0]]["fident"] and \
                        l_alignment[8] >= d_selection[l_alignment[0]]["qlen"]:
                            
                    d_selection = dico_key_value(d_selection, l_alignment, diff_cov)
    
                elif diff_cov <= d_selection[l_alignment[0]]["diff_cov"] and \
                    l_alignment[2] >= d_selection[l_alignment[0]]["fident"] and \
                        l_alignment[8] >= d_selection[l_alignment[0]]["qlen"]:
                    
                    d_selection = dico_key_value(d_selection, l_alignment, diff_cov)
                    
    return d_selection


def write_alphafold_alignment(d_selection):
    """
    Écriture du fichier contenant les alignement sélectionné    
    
    Parameters
    ----------
    d_selection : DICT
        Dictionnaire contenant les informations concernant les alignements sélectionné.
        Un seul alignement par séquence a été sélectionné.
        La clé du dictionnaiore correspond à l'identifiant de la séquence aligné
            contre la base de données AlphaFold Cluster.

    Returns
    -------
    None.

    """
    f_aln_selection = open("alphafold_alignment_selection.tsv", "w")
    
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
            str(value["diff_cov"])
            ]

        f_aln_selection.write('\t'.join(l_alignement) + '\n')

    f_aln_selection.close()


if __name__ == '__main__':
    args = get_args()
    main(args)