"""
This script just defines function(s) for python interpretation.
"""

# Importing modules
import astunparse
import ast
import pandas as pd
import numpy as np
import inspect

# read lol_champions data set
lol_champions = pd.read_csv('lol_champions.csv')
lol_champions = lol_champions.iloc[0:5, 0:7]


def dequote(s):
    """
    If a string has single or double quotes around it, remove them.
    Make sure the pair of quotes match.
    If a matching pair of quotes is not found, return the string unchanged.
    """
    if (s[0] == s[-1]) and s.startswith(("'", '"')):
        return s[1:-1]
    return s


txt = 'pd.DataFrame([["amumu", 2], ["jinx", 3]], columns=["col1", "col2"])'
df = dequote(txt)
df2 = pd.read_csv(df)
print(df2)

