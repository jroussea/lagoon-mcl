#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Jan 19 13:58:16 2026

@author: jrousseau
"""

import os
import gzip
import shutil
import requests
import subprocess
from Bio import SeqIO
from tqdm import tqdm
from bin import uniprot
from bin import download_alphafolddb

def extract_sequence(fasta, fast_list):
    
    s_sequences = set()
    
    with open(fast_list, "r") as file:
        for row in file:
            l_row = row.strip().split("\t")
            s_sequences.add(l_row[0])
    
    f_output = open("tmp/sequences_alphafold_clusters.fasta", "w")
    
    total_fasta = sum(1 for _ in SeqIO.parse(fasta, "fasta"))
    
    for record in tqdm(SeqIO.parse(fasta, "fasta"), total=total_fasta, unit="seq", unit_scale=True):
        if record.id in s_sequences:
            SeqIO.write(record, f_output, "fasta")    

    f_output.close()


def download_file(url, filename_input):
    """Télécharge un fichier avec une barre de progression"""

    response = requests.get(url, stream=True)
    response.raise_for_status()

    # Taille totale du fichier (en octets)
    total_size = int(response.headers.get('content-length', 0))
    chunk_size = 1024  # 1 KB

    # tqdm pour la barre de progression
    with open(filename_input, "wb") as f, tqdm(total=total_size, unit='B', unit_scale=True, desc=filename_input) as bar:
        for chunk in response.iter_content(chunk_size=chunk_size):
            if chunk:  # filtre les keep-alive chunks
                f.write(chunk)
                bar.update(len(chunk))

    print(f"Téléchargé : {filename_input}")
    
def gunzip_file(filename_input, filename_output):
    
    # Taille du fichier compressé
    file_size = os.path.getsize(filename_input)
    
    with gzip.open(filename_input, "rb") as f_in, open(filename_output, "wb") as f_out:
        for chunk in tqdm(iter(lambda: f_in.read(1024*1024), b""), total=file_size//(1024*1024)+1, unit="MB"):
            f_out.write(chunk)

    print(f"Fichier décompressé : {filename_output}")
    

def mmseqs2():
    new_dir = "tmp/alphafoldDB"
    os.makedirs(new_dir, exist_ok=True)
    cmd = [
        "mmseqs", 
        "createdb",
        "tmp/sequences_alphafold_clusters.fasta",
        "tmp/alphafoldDB/alphafoldDB"
        ]    
    subprocess.run(cmd, check=True)


def build_alphafold_db(urls):

    for position, informations in urls.items():
        
        print(position)
        
        url = informations["url"]
        filename_input = informations["filename_input"]
        filename_output = informations["filename_output"]
        
        download_file(url, f"tmp/{filename_input}")
        
        if position == 0:
            
            print("start 0")
            
            #download_file(url, f"tmp/{filename_input}")
            gunzip_file(f"tmp/{filename_input}", f"tmp/{filename_output}")
            download_alphafolddb.main(f"tmp/{filename_output}", "tmp/sequences_id_alphafold_cluster_foldseek.txt")

        elif position == 1:
            
            print("start 1")
            
            extract_sequence(informations["url"], "tmp/sequences_id_alphafold_cluster_foldseek.txt")        
            mmseqs2()

        elif position == 2:

            print("start 2")

            download_file(url, filename_input)
            uniprot.main("tmp/1-AFDBClusters-entryId_repId_taxId.tsv", filename_input)
            

def build_pfam_db():
    new_dir = "tmp/pfamDB"
    os.makedirs(new_dir, exist_ok=True)
    cmd = [
        "mmseqs", 
        "databases",
        "Pfam-A.full",
        "tmp/pfamDB/pfamDB",
        "tmp/tmp"
        ]
    subprocess.run(cmd, check=True)



#def main(database):
def main():    
    database = "all"
    
    new_dir = "tmp"
    os.makedirs(new_dir, exist_ok=True)
    
    urls = {
            0: {
                "url": "https://afdb-cluster.steineggerlab.workers.dev/1-AFDBClusters-entryId_repId_taxId.tsv.gz",
                "filename_input": "1-AFDBClusters-entryId_repId_taxId.tsv.gz",
                "filename_output": "1-AFDBClusters-entryId_repId_taxId.tsv"
                },
            1: {
                "url": "https://ftp.ebi.ac.uk/pub/databases/alphafold/sequences.fasta",
                "filename_input": "sequences.fasta",
                "filename_output": None
                },
            2: {
                "url": "https://ftp.ebi.ac.uk/pub/databases/interpro/current_release/protein2ipr.dat.gz",
                "filename_input": "protein2ipr.dat.gz",
                "filename_output": None
                }
            }

    if database == "alphafold":
        print("\nDownload AlphaFold database\n")
        build_alphafold_db(urls)
        shutil.move("tmp/alphafoldDB", "../database/")
        shutil.move("tmp/uniprot_function.json", "../database/")
        
    elif database == "pfam":
        build_pfam_db()
        shutil.move("tmp/pfamDB", "../database/")
    
    elif database == "all":
        print("\nDownload AlphaFold database\n")
        build_alphafold_db(urls)
        print("\nDownload Pfam database\n")
        build_pfam_db()
        shutil.move("tmp/alphafoldDB", "../database/")
        shutil.move("tmp/uniprot_function.json", "../database/")
        shutil.move("tmp/pfamDB", "../database/")
        shutil.rmtree("tmp")



if __name__ == '__main__':
    main()
