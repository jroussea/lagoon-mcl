#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Mar  1 13:53:58 2024

@author: jeremy
"""

import json
import pandas as pd
import sys
import numpy as np


def load_data(path_annotation, path_correspondance_table, path_json_file):
    """
    chargement de tous les jeux de données
    """

    correspondance_table = pd.read_table(path_correspondance_table, sep=";",
                                         names=["annotation_sequence_header",
                                                "sequence_header", "file_name",
                                                "darkdino_sequence_id"],
                                         header=None)

    with open(path_json_file) as json_file:
        jsonList = json.load(json_file)

    annotation_dataframe = pd.read_table(path_annotation)
    annotation_dataframe = annotation_dataframe.replace({np.nan: "None"})

    return(annotation_dataframe, correspondance_table, jsonList)


def darkdino_sequence_id(jsonList):
    """
    en entré json list
    cette fonction permet de récupérer les identifiants de chaque
    en sortie 2 formes pour les identifiants =1 dataframe et 1 liste
    """

    list_sequence_id = []

    for dico in jsonList:
        list_sequence_id.append(dico["darkdino_sequence_id"])

    df_sequence_id = pd.DataFrame(list_sequence_id,
                                  columns=['darkdino_sequence_id'])

    return(df_sequence_id, list_sequence_id)


def merge_dataframe(correspondance_table, df_sequence_id, annotation_dataframe,
                    columns):
    """
    permet de mettre les identifiant dans le fichier d'annotation à partir 
    de la table de correspondance
    """

    all_correspondance = pd.merge(df_sequence_id, correspondance_table,
                                  how="left", on="darkdino_sequence_id")
    all_correspondance = all_correspondance.replace({np.nan: "None"})

    all_annotation = pd.merge(all_correspondance, annotation_dataframe,
                              how="left",
                              left_on="annotation_sequence_header",
                              right_on=columns)
    all_annotation = all_annotation.replace({np.nan: "None"})

    dict_all_correspondance = all_annotation.to_dict(orient="records")

    return(dict_all_correspondance, all_annotation)


def general_information(list_sequence_id, jsonList, dict_all_correspondance):
    """
    """

    for position, sequence_id in enumerate(list_sequence_id):

        jsonList[position]["annotation_sequence_header"] = \
            dict_all_correspondance[position]["annotation_sequence_header"]

    return(jsonList)


def condition1(all_annotation_drop, json_data):
    """
    """

    all_columns = all_annotation_drop.columns.tolist()
    all_columns.remove("darkdino_sequence_id")

    dict_sequence = {}

    count = 0
    for dictionary in json_data:

        dict_tmp = {}
        dict_tmp_2 = {}

        for col in all_columns:

            dict_tmp.update({col: dictionary[col]})

        if dictionary["darkdino_sequence_id"] in dict_sequence:

            dict_intermediate = dict_sequence[dictionary["darkdino_sequence_id"]]

            list_key = [str(key) for key in dict_tmp.keys()]

            for key in list_key:

                if isinstance(dict_intermediate[key], list):

                    list_intermediate = dict_intermediate[key]
                    list_intermediate.append(dict_tmp[key])

                    dict_tmp_2[key] = list(set(list_intermediate))

                else:

                    list_intermediate = [dict_tmp[key], dict_intermediate[key]]

                    dict_tmp_2[key] = list(set(list_intermediate))

            dict_sequence[dictionary["darkdino_sequence_id"]] = dict_tmp_2

        else:

            dict_sequence[dictionary["darkdino_sequence_id"]] = dict_tmp

        count += 1

    return(dict_sequence)


def condition2(columns_condition, all_annotation_drop, json_data):

    """
    """
    
    list_columns = list(columns_condition.split(","))
    id_columns = list_columns.pop(0)

    all_columns = all_annotation_drop.columns.tolist()

    for value in list_columns:
        all_columns.remove(value)
    all_columns.remove(id_columns)
    all_columns.remove("darkdino_sequence_id")

    dict_sequence = {}

    count = 0
    for dictionary in json_data:

        dict_tmp = {}

        for col in all_columns:

            dict_tmp.update({col: dictionary[col]})

        dict_sequence[dictionary["darkdino_sequence_id"]] = dict_tmp

        count += 1


    count = 0
    for dictionary in json_data:

        dict_tmp = {}
        dict_intermediate = {}

        for col in list_columns:

            dict_intermediate[col] = dictionary[col]

        dict_tmp[dictionary[id_columns]] = dict_intermediate
        
        if id_columns in dict_sequence[dictionary["darkdino_sequence_id"]]:

            dict_sequence[dictionary["darkdino_sequence_id"]][id_columns] \
                .update(dict_tmp)
                
        else:

            dict_sequence[dictionary["darkdino_sequence_id"]][id_columns] = \
                dict_tmp

        count += 1
    
    return(dict_sequence)


def condition3(columnsInfos, columnsAnnot, all_annotation_drop, json_data):
    """
    """

    list_columnsInfos = list(columnsInfos.split(","))
    id_columnsInfos = list_columnsInfos.pop(0)
    list_columnsAnnot = list(columnsAnnot.split(","))
    id_columnsAnnot = list_columnsAnnot.pop(0)
    all_columns = all_annotation_drop.columns.tolist()

    for value in list_columnsInfos:
        all_columns.remove(value)
    for value in list_columnsAnnot:
        all_columns.remove(value)
    all_columns.remove(id_columnsAnnot)
    all_columns.remove("darkdino_sequence_id")

    dict_sequence = {}

    count = 0
    for dictionary in json_data:

        dict_tmp = {}

        for col in all_columns:

            dict_tmp.update({col: dictionary[col]})

        dict_sequence[dictionary["darkdino_sequence_id"]] = dict_tmp

        count += 1

    count = 0
    for dictionary in json_data:

        dict_intermediate = {}
        dict_tmp_annot = {}
        dict_tmp_infos = {}

        for col in list_columnsInfos:

            dict_intermediate[col] = dictionary[col]

        dict_tmp_infos[dictionary[id_columnsInfos]] = dict_intermediate
        dict_tmp_annot[dictionary[id_columnsAnnot]] = \
            dict_tmp_infos

        if id_columnsAnnot in dict_sequence[dictionary["darkdino_sequence_id"]]:

            dict_key = [str(key) for key in dict_tmp_annot.keys()]
            key = ''.join(dict_key)
            if key in dict_sequence[dictionary["darkdino_sequence_id"]][id_columnsAnnot]:

                dict_sequence[dictionary["darkdino_sequence_id"]
                              ][id_columnsAnnot][key].update(dict_tmp_infos)

            else:
                dict_sequence[dictionary["darkdino_sequence_id"]][id_columnsAnnot] \
                    .update(dict_tmp_annot)

        else:

            dict_sequence[dictionary["darkdino_sequence_id"]][id_columnsAnnot] = \
                dict_tmp_annot

        count += 1

    return(dict_sequence)


def add_information(jsonList, dict_sequence):
    
    """
    ajout des information dabns le ficheir json d'origine
    utiliser le darkdino_id pour rechercher dasn mle dictionnaire dict_sequence
    parser le ficheir json et ajouter de l'info dedans
    """
    
    pass


def save_json(jsonList, basename):
    
    with open (f"{basename}.json", "w") as file:
            json.dump(jsonList, file)


def main(basename, path_annotation, path_json_file, path_correspondance_table,
         columns, columnsAnnot, columnsInfos):
    """

    """

    annotation_dataframe, correspondance_table, jsonList = \
        load_data(path_annotation, path_correspondance_table, path_json_file)

    df_sequence_id, list_sequence_id = darkdino_sequence_id(jsonList)

    dict_all_correspondance, all_annotation = \
        merge_dataframe(correspondance_table, df_sequence_id,
                        annotation_dataframe, columns)

    lenAnnot = len(columnsAnnot)
    lenInfos = len(columnsInfos)

    jsonList = general_information(list_sequence_id, jsonList,
                                   dict_all_correspondance)

    all_annotation_drop = all_annotation.drop(["annotation_sequence_header",
                                               "sequence_header", "file_name",
                                               columns], axis=1)
    
    json_str = all_annotation_drop.to_json(orient='table')

    json_obj = json.loads(json_str)
    json_data = json_obj["data"]
    
    if lenAnnot == 0 and lenInfos == 0:

        """
        """

        dict_sequence = condition1(all_annotation_drop, json_data)
    
    elif lenAnnot >= 1 and lenInfos == 0:

        """
        création des dicos différents dico

        avec un dico de dico pour la première option
        """
        dict_sequence = condition2(columnsAnnot, all_annotation_drop, json_data)
    
    elif lenAnnot == 0 and lenInfos >= 1:

        """
        même chose que la condition précédente
        """
        dict_sequence = condition2(columnsInfos, all_annotation_drop, json_data)

    elif lenAnnot >= 1 and lenInfos >= 1:

        """
        si info dans la deuxième option

        IMPORTANNT la clé de la deuxième option doit correspondre une valeur de
        la valeur de la première

        dico de dico de dico

        jsonlist{option1 : {option 2: {valeur 1}}}
        """

        dict_sequence = condition3(columnsInfos, columnsAnnot, all_annotation_drop,
                                   json_data)
    
    for dictionary in jsonList:
                
        dictionary["sequence_information"] = dict_sequence[dictionary["darkdino_sequence_id"]]
        
    save_json(jsonList, basename)
    
    return(jsonList)
    

if __name__ == '__main__':
    
    basename = sys.argv[1]
    path_annotation = sys.argv[2]
    path_json_file = sys.argv[3]
    path_correspondance_table = sys.argv[4]
    columns = sys.argv[5]
    columnsAnnot = sys.argv[6]
    columnsInfos = sys.argv[7]

    main(basename, path_annotation, path_json_file, path_correspondance_table,
             columns, columnsAnnot, columnsInfos)
