#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Oct 31 09:39:42 2024

@author: jrousseau
"""


import pandas as pd
from argparse import ArgumentParser


def get_args():
    """
    Parse arguments
    """
    
    parser = ArgumentParser(description="")
    
    parser.add_argument("-n", "--network", type = str,
                        help = "Network obtained after clustering with MCL", 
                        required = True)
    parser.add_argument("-i", "--inflation",  type = float,
                        help="Clustering inflation level (MCL parameter)", 
                        required = True)

    return parser.parse_args()


def main(args):
    
    list_dict = []

    with open(args.network) as clustering:
        for position, cluster in enumerate(clustering):
            print(position)
            cluster = cluster.strip()
            list_node = cluster.split('\t')
            for i in list_node:
                dict_node = {'cluster_id': position, 
                             'protein_accession': i,
                             'inflation': args.inflation}
                list_dict.append(dict_node)


    df_network = pd.DataFrame.from_dict(list_dict)
    
    df_network.to_csv(f"network_I{args.inflation}.tsv", 
                     sep = "\t", index = None, header = False)


if __name__ == '__main__':
    args = get_args()
    main(args)
    
    
"""
df_clustering = pd.DataFrame(columns=['A','B'])


list_dict = []

with open("dump.out.network.mci.I14") as clustering:
    for position, cluster in enumerate(clustering):
        print(position)
        cluster = cluster.strip()
        list_node = cluster.split('\t')
        for i in list_node:
            dict_node = {'A': position, 'B': i}
            list_dict.append(dict_node)


plaf = pd.DataFrame.from_dict(list_dict) 







with open("dump.out.network.mci.I14") as clustering:
    for position, cluster in enumerate(clustering):
        print(position)
        cluster = cluster.strip()
        list_node = cluster.split('\t')
        df_cluster = pd.DataFrame(np.array([list_node]).T)
        df_cluster.columns = ['B']
        df_cluster.insert(loc = 0, column="A", value = position)

        df_clustering = pd.concat([df_clustering, df_cluster], ignore_index = False)



plouf = df_cluster.to_dict('records')
df_clustering = df_clustering.append(plouf)


df_clustering = df_clustering.append(plouf)
df_clustering.loc[len(df_clustering)] = plouf

df_clustering = df_clustering.reset_index(drop=True)
"""
