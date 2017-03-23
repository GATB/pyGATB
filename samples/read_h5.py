import os
from pyGATB.graph import Graph

F_NAME='celegans_reads.h5'

print ("File size: %.d kb" % (os.stat(F_NAME).st_size / 1024))

graph = Graph('-in %s' % F_NAME)

for i, node in enumerate(graph):
    print('{}: {!r}'.format(i, node))
    if i > 10: break
