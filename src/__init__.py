"""
Two main gatb-core API are exposed in python :
    * Graph: for constructing and loading gatb graph
    * Bank: for loading sequences from FASTA, FASTAQ, and text file defining collections.
"""
__all__ = ['Bank', 'Graph']

import os

# Import public facing API for re-export
from .core import Bank, Graph

# Get version from VERSION file
with open(os.path.join(os.path.dirname(__file__), 'VERSION')) as f:
    __version__ = f.read().strip()
del f, os
