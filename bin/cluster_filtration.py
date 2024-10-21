#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Oct 18 19:15:54 2024

@author: jrousseau
"""

import sys


def main(path, inflation, min_size):
    with open(path,"r") as file :
        
        for line in file:
            
            list_line = len(line.split("\t"))
    
            if int(list_line) >= int(min_size):
                with open(f"conserved_cluster_{inflation}.txt", 'a', encoding = 'utf8') as f:
                    f.write(line)
            
            else:
                with open("unconserved_clusters.txt", 'a', encoding = 'utf8') as f:                
                    f.write(line)


if __name__ == '__main__':
    
    path = sys.argv[1]
    inflation = sys.argv[2]
    min_size = sys.argv[3]

    main(path, inflation, min_size)
    

#path = "dump.out.network.mci.I14"
#inflation = "1.4"
#min_size = 10

#main(path, inflation, min_size)

