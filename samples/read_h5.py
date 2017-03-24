# we import pyGATB Graph
from pyGATB.graph import Graph

# We will use a file containing a De Bruijn Graph stored
# in HDF5 format; file created using dbgh5 tool provided
# with GATB-Core. (This file is located next to this snippet)
F_NAME='celegans_reads.h5'

# We create the graph
graph = Graph('-in %s' % F_NAME)

# We iterate over some nodes
for i, node in enumerate(graph):
    print('{}: {!r}'.format(i, node))
    if i > 10: break
