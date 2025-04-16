#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Feb 25 11:11:01 2025

@author: jroussea
@date: 2025-02-28
@version: 1.0
@contact: https://github.com/jroussea/lagoon-mcl/discussions
@license: MIT License
@description: This script checks whether the files supplied by the user are in the correct format
"""


import sys
import re
from argparse import ArgumentParser


def main(args):
    """

    Parameters
    ----------
    args.input: FASTA or TSV or CSV
        User-supplied annotation file
    args.delimiter: "\t" or ","
        Delimiter for tsv and csv files
    args.test: STR
        Test type (fasta file, CSV file or TSV file)
    args.name: STR
        Test name

    """
    if args.test == "csv":
        check_csv_input(args.input, args.delimiter, args.name)

    elif args.test == "label":
        check_label_input(args.input, args.delimiter, args.name)

    elif args.test == "fasta":
        check_fasta_format(args.input, args.name)


def get_args():
    """
    Parse arguments
    
    """
    parser = ArgumentParser(description="This script checks whether the files supplied by the user are in the correct format")
    
    parser.add_argument("-i", "--input", type = str,
                        help = "User-supplied annotation file", 
                        required = True)
    
    parser.add_argument("-d", "--delimiter", type = str,
                        help = "Delimiter for tsv and csv files", 
                        required = False,
                        default = "\t")
    
    parser.add_argument("-t", "--test", type = str,
                        help = "Test type (fasta file, CSV file or TSV file)",
                        required = True)

    
    parser.add_argument("-n", "--name", type = str,
                        help = "Test name",
                        required = True)
    
    return parser.parse_args()


def check_csv_input(input_file, delimiter, name):
    """
    Test function for CSV files

    Parameters
    ----------
    input_file : STR
        CSV file with two columns.
            Column 1: [database] name of the database from which the labels originate (e.g.: Gene3D, Pfam, FunFam).
            Column 2: [file] path to files containing labels
    delimiter : STR
        File delimiter, must be a comma (,).
    name : STR
        Test name for this function: csv.

    Raises
    ------
    ValueError
        Test 1: the delemiter is not a comma
        Test 2: first column header is not “annotation”
        Test 3: second column header is not “file”
        
    Returns
    -------
    None.

    """
    l_failed_test = list()
    
    print("INPUT TEST: CSV file")
    
    with open(input_file, "r") as f_input:
    
        """Test 1"""
        try:  
            header = f_input.readline().strip()
            columns = header.split(delimiter)
            if len(columns) == 2:
                print(f"Test 1 OK: The delimiter must be comma (current separator: {delimiter}) and the number of columns must be equal to 2.")
            else:
                length = len(columns)
                raise ValueError(f"The delimiter must be comma (current separator: {delimiter}) and the number of columns must be equal to 2 (current number of columns: {length})")
        except ValueError as e:
            print(f"Test 1 Error: {e}")
            l_failed_test.append(f"Test 1 Error: {e}")
    
        """Test 2"""
        try:
            if columns[0] == "annotation":
                print("Test 2 OK: First column name is correct (\"annotation\")")
            else:
                raise ValueError("The name of the first column must be \"annotation\".")
        except ValueError as e:
            print(f"Test 2 Error: {e}")
            l_failed_test.append(f"Test 2 Error: {e}")
    
        """Test 3"""
        try:
            if columns[1] == "file":
                print("Test 3 OK: The name of the second column is correct (\"file\")")
            else:
                raise ValueError("The name of the first column must be \"file\"")
        except ValueError as e:
            print(f"Test 3 Error: {e}")
            l_failed_test.append(f"Test 3 Error: {e}")

    if len(l_failed_test) > 0:
        with open(f"failed_test_csv_input_{name}.txt", "w") as f_output:
            f_output.write("\n".join(l_failed_test))
        sys.exit(1)
    else:
        with open(f"failed_test_csv_input_{name}.txt", "w") as f_output:
            f_output.write("All tests successfully passed")
        print("All tests successfully passed")
    

def check_label_input(input_file, delimiter, name):
    """
    Test function for TSV files

    Parameters
    ----------
    input_file : STR
        Two-column TSV file.
            Column 1: sequence ID
            Column 2: sequence-specific label IDs. 
                        If several labels, they are separated by a semicolon (“;”).
    delimiter : STR
        File delimiter, must be a semicolon (";").
    name : STR
        Test name for this function: name in the first column of the CSV file.
    Raises
    ------
    ValueError
        Test 1: the delimiter is not a delimiter
        Test 2: first column header is not "sequence_id"
        Test 3: seconde column header is not "label"
        Test 4: Sequences IDs (first column) appear several times

    Returns
    -------
    None.

    """
    l_failed_test = list()
    
    print("Label input test")
    
    s_sequence = set()
    
    with open(input_file, "r") as f_input:
        
        """Test 1"""
        try:  
            header = f_input.readline().strip()
            columns = header.split(delimiter)
    
            if len(columns) == 2:
                print(f"Test 1 OK: The delimiter must be a tab ({delimiter}) and the number of columns must be equal to 2.")
            else:
                raise ValueError("The delimiter must be a tab ({delimiter}) and the number of columns must be equal to 2.")
        except ValueError as e:
            print(f"Test 1 Error: {e}")
            l_failed_test.append(f"Test 1 Error: {e}")
            
        """Test 2"""
        try:
            if columns[0] == "sequence_id":
                print("Test 2 OK: The name of the first column must be (\"sequence_id\").")
            else:
                raise ValueError("The name of the first column must be (\"sequence_id\").")
        except ValueError as e:
            print(f"Test 2 Error: {e}")
            l_failed_test.append(f"Test 2 Error: {e}")
        
        """Test 3"""
        try: 
            if columns[1] == "label":
                print("Test 3 OK: The name of the second column must be (\"label\").")
            else:
                raise ValueError("The name of the second column must be (\"label\").")
        except ValueError as e:
            print(f"Test 3 Error: {e}")
            l_failed_test.append(f"Test 3 Error: {e}")
        
        """Test 4"""
        try:
            label_format = True
            for row in f_input:
                l_row = row.rstrip("\n").split("\t")
                
                if l_row[0] not in s_sequence:
                    s_sequence.add(l_row[0])
                else:
                    label_format = False    
                    break
            if label_format:
                print("Test 4 OK: The identifiers corresponding to the fasta sequences must be present at most once in the files containing the labels.")
            else:
                raise ValueError("There can't be more than one sequence identifier (presence of several with the same identifier). If a sequence has several labels, then the labels must be placed in the \"label\" column and separated by a semicolon (;).")
        except ValueError as e:
            print(f'Test 4 Error: {e}')
            l_failed_test.append(f'Test 4 Error: {e}')
            
    if len(l_failed_test) > 0:
        print("Test are failed ")
        with open(f"failed_test_label_input_{name}.txt", "w") as f_output:
            f_output.write("\n".join(l_failed_test))
        sys.exit(1)
    else:
        with open(f"failed_test_label_input_{name}.txt", "w") as f_output:
            f_output.write("All tests successfully passed")
        print("All tests successfully passed")


def check_fasta_format(input_file, name):
    """
    Test function for FASTA files

    Parameters
    ----------
    input_file : FFASTA
        FASTA file, must contain protein sequences
    name : STR
        Test name for this function: fasta.

    Raises
    ------
    ValueError
        Test 1: Sequences are not in fasta format

    Returns
    -------
    None.

    """
    with open(input_file, "r") as f_input:

        """Test 1"""
        try:
            lines = f_input.readlines()
            
            fasta_format = True
            error_fasta = False
            
            for position, line in enumerate(lines):
                position += 1
                line = line.strip()
                
                if line.startswith(">"):
                    continue
                elif re.match("^[ARNDCEQGHILKMFPSTWYVXarnedqghilkmfpstwyvx*]+$", line):
                    continue
                else:
                    print("Invalid format")
                    fasta_format = False
                    break
            if fasta_format:
                print("Test Fasta 0K: The FASTA file format is valid")
            
            else:
                raise ValueError(f"The file contains an invalid line at position {position}. Invalid line: {line}. View file: /outdir/lagoon-mcl_output/diamond/all_sequences.fasta")
            
        except ValueError as e:
            print(f"Test Fasta Error: {e}")
            error_fasta = True
            
    if error_fasta:
        print("Test are failed ")
        with open(f"failed_test_label_input_{name}.txt", "w") as f_output:
            f_output.write("\n".join(["Problem with the FASTA file format.", f"The file contains an invalid line at position {position}. Invalid line: {line}. View file: /outdir/lagoon-mcl_output/diamond/all_sequences.fasta"]))
        sys.exit(1)
    else:
        with open(f"failed_test_label_input_{name}.txt", "w") as f_output:
            f_output.write("All tests successfully passed")
        print("All tests successfully passed")


if __name__ == '__main__':
    args = get_args()
    main(args)