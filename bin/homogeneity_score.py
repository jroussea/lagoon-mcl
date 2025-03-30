#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Feb 27 15:58:43 2025

@author: jroussea
@date: 2025-03-03
@version: 1.0
@contact: https://github.com/jroussea/lagoon-mcl/discussions
@license: MIT License
@description: Ce script permet de ne sélection qu'un seul alignement par pour chaque pair de séquence.
"""


from argparse import ArgumentParser
from collections import Counter
import os
import json


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
    #network, labels = load_file(args.network, args.labels)
    s_cluster, d_size = network_description(args.network)
    output_metrics, output_labels = output_file_preparation(s_cluster, d_size, args.basename)

    s_database = set()
    with open(args.labels, 'r') as f_labels:
        for label in f_labels:
            l_label = label.rstrip("\n").split('\t')
            if l_label[2] not in s_database:
                s_database.update({l_label[2]})

    for database in s_database:
        d_sequence = sequence_label(args.labels, database)
        d_network, d_label = network_information(args.network, d_sequence)
        d_network = homogeneity_score(d_network, d_label, "all")
        # d_network = homogeneity_score(d_network, d_label, "annot")
        save_homogeneity_score(output_metrics, d_network, database)
        write_label_file(output_labels, d_network, database)
        abundance_matrix(d_network, database, args.basename)


def get_args():
    """
    Parse arguments
    """
    parser = ArgumentParser(description="")
    
    parser.add_argument("-l", "--labels", type = str,
                        help = "Path label", 
                        required = True)

    parser.add_argument("-n", "--network", type = str,
                        help = "path network", 
                        required = True)

    parser.add_argument("-b", "--basename", type = str,
                        help = "type d'annotation (pfam, funfam, ...)", 
                        required = True)

    return parser.parse_args()


def load_file(path_network, path_labels):
    """
    chargement des fichier network et label en mémoire
    
    Parameters
    ----------
    path_network : STR
        Fichier TSV contenant le réseau.
            Colonne 1 : identifiant des clusters.
            Colonne 2 : identifiant des séquence / noeuds (1 noeuds par ligne).
    path_labels : STR
        Fichier TSV contenant les labels.
            Colonne 1 : identifiant des séquences (1 séquence par ligne)
            Colonne 2 : Identifiant des labels, si plusieurs label pour une séquence 
                            alors il doivent être séparé par un poitn virgule

    Returns
    -------
    network : LIST
        List du fichier network, 1 position = 1 ligne dans le fichier.
    labels : LIST
        List du fichier label, 1 position = 1 ligne dans le fichier.

    """
    with open(path_network, "r") as f_input:
        network = f_input.readlines()
    
    with open(path_labels, "r") as f_input:
        labels = f_input.readlines()
        
    return network, labels


def network_description(network):
    """
    deption générale des cluster (nombre de noeuds)

    Parameters
    ----------
    network : LIST
        List du fichier network, 1 position = 1 ligne dans le fichier.

    Returns
    -------
    s_cluster : SET
        set de tous les cluster identifiants de cluster (0, 1, 2, 3, ...).
    d_size : DICT
        Dictionnaire de la taille des clusters (nombre de noeuds par cluster).

    """
    s_cluster = set()
    d_size = dict()

    with open(network, 'r') as f_network:
        
        for position, node in enumerate(f_network):
            if position != 0:
                l_node = node.rstrip("\n").split("\t")
                s_cluster.add(l_node[0])
                if l_node[0] not in d_size.keys():
                    d_size[l_node[0]] = 1
                elif l_node[0] in d_size.keys():
                    d_size[l_node[0]] += 1
    
    return s_cluster, d_size


def output_file_preparation(s_cluster, d_size, basename):
    """
    Préparation du ficheir de sortie, en y mettant les deux première colonne 
        colonne 1 [cluster_id] : identifiant des cluster
        colonne 2 [cluster_size] : taille des clusters (nombre de noeuds)

    Parameters
    ----------
    s_cluster : SET
        set de tous les cluster identifiants de cluster (0, 1, 2, 3, ...).
    d_size : DICT
        Dictionnaire de la taille des clusters (nombre de noeuds par cluster).
    basename : STR
        Nom du fichier réseau (network_I[inflation]).

    Returns
    -------
    output : STR
        Nom du fichier de sortie.

    """
    output_metrics = f"homogeneity_score_{basename}.tsv"
    output_labels = f"clusters_labels_{basename}.tsv"
    
    f_homogeneity = open(output_metrics, 'w')
    f_labels = open(output_labels, 'w')
    
    f_homogeneity.write("cluster_id\tcluster_size\n")
    f_labels.write("cluster_id\n")
    for key, value in d_size.items():
        f_homogeneity.write('\t'.join([str(key), str(value)]) + '\n')
        f_labels.write(f'{str(key)}\n')
    
    f_labels.close()
    f_homogeneity.close()

    return output_metrics, output_labels


def sequence_label(labels, database):
    """
    Descriptions des séquences

    Parameters
    ----------
    labels : LIST
        List du fichier label, 1 position = 1 ligne dans le fichier.
    database : STR
        base de donnnées en cours d'analyse (par exemple : FunFam, Pfam, Gene3D).

    Returns
    -------
    d_sequence : DICT
        Clé: identifiant des séquences.
        Valeur : liste de tous les label lié à la séquence

    """
    d_sequence = dict()
    with open(labels, 'r') as f_labels:
        for label in f_labels:
            l_label = label.rstrip("\n").split('\t')
            if l_label[2] == database and l_label[1] != "NA":
                if l_label[0] not in d_sequence.keys():
                    d_sequence[l_label[0]] = l_label[1].split(";")
                else:
                    d_sequence[l_label[0]].append(l_label[1].split(";"))
    
    return d_sequence


def network_information(network, d_sequence):
    """
    Descriptions du réseau 

    Parameters
    ----------
    network : LIST
        List du fichier network, 1 position = 1 ligne dans le fichier.
    d_sequence : DICT
        Clé: identifiant des séquences.
        Valeur : liste de tous les label lié à la séquence

    Returns
    -------
    d_network : DICT
        Clé : Identifiant des cluster
        Valeur : Dict. Clé - Valeur :
            protein_accession - liste de tous les noeuds
            label - liste des séquences avec au moins un label
            sequence_annotated - nomvbre de séquence avec au moins un label
    d_label : DICT
        Clé : identifiant des clusters.
        Valeur : set de tous les labels qui compose le cluser.

    """
    d_network = dict()
    d_label = dict()

    with open(network, 'r') as f_network:
        for position, node in enumerate(f_network):
            if position != 0:
                l_node = node.rstrip("\n").split('\t')
                    
                ############################
                #### Dictionary d_label ####
                ############################
                
                if l_node[0] not in d_label:
                    d_label[l_node[0]] = {}
                if l_node[1] in d_sequence:
                    l_label = str(d_sequence[l_node[1]][0]).split(";")
                    for label in set(l_label):
                        if label not in d_label[l_node[0]]:
                            d_label[l_node[0]][label] = {l_node[1]}
                        else:
                            d_label[l_node[0]][label].add(l_node[1])
                     
                ##############################
                #### Dictionary d_network ####
                ##############################
        
                l_node = node.rstrip("\n").split('\t')
                
                if l_node[0] not in d_network and l_node[1] in d_sequence:
                    # si le cluster n'a pas encore été vu et que la séquence 
                    d_network[l_node[0]] = {'protein_accession': [l_node[1]],
                                            'label': d_sequence[l_node[1]],
                                            'all_label': d_sequence[l_node[1]],
                                            'sequence_annotated': 1}
        
                elif l_node[0] not in d_network and l_node[1] not in d_sequence:
                    d_network[l_node[0]] = {'protein_accession': [l_node[1]],
                                            'label': [],
                                            'all_label': [],
                                            'sequence_annotated': 0}
        
                elif l_node[0] in d_network and l_node[1] in d_sequence:
                    d_network[l_node[0]]['protein_accession'].append(l_node[1])
                    d_network[l_node[0]]['label'] = d_network[l_node[0]]['label'] + d_sequence[l_node[1]]
                    d_network[l_node[0]]['all_label'] = d_network[l_node[0]]['all_label'] + d_sequence[l_node[1]]
                    d_network[l_node[0]]['sequence_annotated'] += 1
        
                elif l_node[0] in d_network and l_node[1] not in d_sequence:
                    d_network[l_node[0]]['protein_accession'].append(l_node[1])
    
    return d_network, d_label


def negative_homogeneity_score(d_label, key):
    """
    Calcul du score d'homogénéité si celui si est négatif.
    Il est négatif quand le nombre de label est supérieur au nombre de noeud dans le cluster
    Pour cela, sélection des label qui réprésente au mieux les séquences annoté

    Parameters
    ----------
    d_label : DICT
        Clé : identifiant des clusters.
        Valeur : set de tous les labels qui compose le cluser.
    key : STR
        Identifiant du cluster.

    Returns
    -------
    l_label_select : LIST
        Liste des labels sélectionné.

    """
    l_label_select = list()
    
    s_node = set()
    
    d_cluster_label = d_label[key]
    
    d_cluster_label_size = dict()
    
    for label in d_cluster_label:
        d_cluster_label_size[label] = len(d_cluster_label[label])
        s_node = s_node | d_cluster_label[label]
    
    while len(s_node) > 0:
        
        max_label = max(d_cluster_label_size, key=d_cluster_label_size.get)
        
        l_label_select.append(max_label)
        s_node = s_node - d_cluster_label[max_label]
        
        d_cluster_label = {key:value - d_cluster_label[max_label] for key, value in d_cluster_label.items()}
        
        for label in d_cluster_label:
            d_cluster_label_size[label] = len(d_cluster_label[label])
    
    return l_label_select


def homogeneity_score(d_network, d_label, homogeneity_score):
    """
    Calcul du score d'homogénétié
    Si le nombre de label unique est égale à 1 => homogénéity score = 1
    Si le nombre de labale unique strictement supérieur à 1 => homogénéity score = 1 - nombre de label / nombre de noeud
    Si il n'y a pas de label dans le cluster => homogénéity score = NA
    
    Parameters
    ----------
    d_network : DICT
        Clé : Identifiant des cluster
        Valeur : Dict. Clé - Valeur :
            protein_accession - liste de tous les noeuds
            label - liste des séquences avec au moins un label
            sequence_annotated - nomvbre de séquence avec au moins un label
    d_label : DICT
        Clé : identifiant des clusters.
        Valeur : set de tous les labels qui compose le cluser.
    homogeneity_score : STR
        all ou annot ;: en cours d'implémentation.

    Returns
    -------
    d_network : DICT
        Mise jours du d_nework donné en entré.
        Clé : Identifiant des cluster
        Valeur : Dict. Clé - Valeur :
            protein_accession - liste de tous les noeuds
            label - liste des séquences avec au moins un label
            sequence_annotated - nomvbre de séquence avec au moins un label
            homogenity_score_{homogeneity score variable} - score d'homogénéité du cluster

    """
        
    for key in d_network:
        
        if homogeneity_score == "all":
            divisor = len(set(d_network[key]["protein_accession"]))
        elif homogeneity_score == "annot":
            divisor = d_network[key]["sequence_annotated"]
        s_key = f"homogeneity_score_{homogeneity_score}"
        
        d_network[key]["label"] = list(set(d_network[key]["label"])) # J'ai souvent eu des problèmes avec cette ligne. Normalement c'est réglé.

        if len(d_network[key]["label"]) == 1:
            d_network[key][s_key] = 1
            
            
            
        elif len(d_network[key]["label"]) > 1:
        
            hom_sc = 1 - (len(set(d_network[key]["label"])) / divisor)

            if hom_sc < 0:
                l_label_select = negative_homogeneity_score(d_label, key)
                
                hom_sc = 1 - (len(set(l_label_select)) / len(set(d_network[key]["protein_accession"])))
                
            d_network[key][s_key] = hom_sc
            
        else:
            d_network[key][s_key] = 'NA'

    return d_network


def save_homogeneity_score(output_metrics, d_network, database):
    """
    Sauvegarde du score d'homogénéité et du nombre de séquence annoté pour 
    une base de données dans le fichier de sortie

    Parameters
    ----------
    output : STR
        Nom du fichier de sortie créé dans la fonction : output_file_preparation.
    d_network : DICT
        Mise jours du d_nework donné en entré.
        Clé : Identifiant des cluster
        Valeur : Dict. Clé - Valeur :
            protein_accession - liste de tous les noeuds
            label - liste des séquences avec au moins un label
            sequence_annotated - nomvbre de séquence avec au moins un label
            homogenity_score_{homogeneity score variable} - score d'homogénéité du cluster
    database : STR
        Nom de la base de données utilisé pour le calcul du score d'homogénéité (par exemple FunFam, Pfam, Gene3D).

    Returns
    -------
    None.

    """
    with open(output_metrics, 'r') as f_input:
        with open('temporary', 'w') as f_temp:
            for position, line in enumerate(f_input):
                if position == 0:
                    modified_line = line.strip() + f"\t{database}_homogeneity_score\t{database}_sequence\t{database}_numbre_labels\n"
                else:
                    l_line = line.strip().split("\t")
                    homsc = str(d_network[l_line[0]]["homogeneity_score_all"])
                    seq = str(d_network[l_line[0]]["sequence_annotated"])
                    labels = str(len(set(d_network[l_line[0]]["label"])))
                    modified_line = line.strip() + f"\t{homsc}\t{seq}\t{labels}\n"
                
                f_temp.write(modified_line)

    os.replace("temporary", output_metrics)


def write_label_file(output_labels, d_network, database):
    """
    

    Parameters
    ----------
    d_network : DICT
        Mise jours du d_nework donné en entré.
        Clé : Identifiant des cluster
        Valeur : Dict. Clé - Valeur :
            protein_accession - liste de tous les noeuds
            label - liste des séquences avec au moins un label
            sequence_annotated - nomvbre de séquence avec au moins un label
            homogenity_score_{homogeneity score variable} - score d'homogénéité du cluster
    database : STR
        Nom de la base de données utilisé pour le calcul du score d'homogénéité.
    basename : STR
        Nom du fichier réseau.

    Returns
    -------
    None.

    """
    with open(output_labels, "r") as f_input:
        with open("temporary", "w") as f_temp:
            for position, line in enumerate(f_input):
                if position == 0:
                    modified_line = line.strip() + f"\t{database}\n"
                else:
                    l_line= line.strip().split("\t")
                    labels = set(d_network[l_line[0]]["label"])
                    modified_line = line.strip() + f"\t{';'.join(labels)}\n"
                f_temp.write(modified_line)

    os.replace("temporary", output_labels)


def abundance_matrix(d_network, database, basename):
    
    d_abundance = dict()
    for key, value in d_network.items():
        if value["all_label"]:
            d_abundance[key] = dict(Counter(value["all_label"]))

    with open(f"abundance_matrix_{database}_{basename}.json", "w") as f_output:
        json.dump(d_abundance, f_output)


if __name__ == '__main__':
    args = get_args()
    main(args)
    


# network, labels = load_file("network_I14.tsv", "labels.tsv")
# s_cluster, d_size = network_description("network_I14.tsv")
# output_metrics, output_labels = output_file_preparation(s_cluster, d_size, "POUAC")

# s_database = set()
# with open("labels.tsv", 'r') as f_labels:
#     for label in f_labels:
#         l_label = label.rstrip("\n").split('\t')
#         if l_label[2] not in s_database:
#             s_database.update({l_label[2]})

# for database in s_database:
#     print(database)
#     d_sequence = sequence_label("labels.tsv", database)
#     d_network, d_label = network_information("network_I14.tsv", d_sequence)
#     d_network = homogeneity_score(d_network, d_label, "all")
#     # d_network = homogeneity_score(d_network, d_label, "annot")
#     save_homogeneity_score(output_metrics, d_network, database)
#     write_label_file(output_labels, d_network, database)
#     abundance_matrix(d_network, database, "POUAC")
