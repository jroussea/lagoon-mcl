#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Mar  6 16:15:06 2024

@author: jeremy
"""


import pandas as pd
import sys


df = pd.read_csv("dump.out.seq.mci.I40", sep = "\t", header = None)
lst_columns = df.columns.tolist()

df["CC"] = df.index
col = df.pop("CC")
df.insert(0, col.name, col)

plouf = pd.melt(df, id_vars=["CC"], value_vars=lst_columns)
plouf.pop("variable")
plouf = plouf.dropna()

