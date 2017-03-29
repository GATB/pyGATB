"""
Two main gatb-core API are exposed in python :
    * Graph: for constructing and loading gatb graph
    * Bank: for loading sequences from FASTA, FASTAQ, and text file defining collections.
"""
__all__ = ['Bank', 'Graph']

import os

# Import public facing API for re-export
from .core import Bank, Graph

__version__ = open(os.path.join(os.path.dirname(__file__), 'VERSION')).read().strip()
