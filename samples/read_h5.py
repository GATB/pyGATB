# ===========================================================================
#   pyGATB : Python3 wrapper for GATB-Core
#   Copyright (C) 2017 INRIA
#   Author: Mael Kerbiriou
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU Affero General Public License as
#  published by the Free Software Foundation, either version 3 of the
#  License, or (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU Affero General Public License for more details.
#
#  You should have received a copy of the GNU Affero General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.
# ===========================================================================

# we import pyGATB Graph
from pyGATB.graph import Graph

# We will use a file containing a De Bruijn Graph stored
# in HDF5 format; file created using dbgh5 tool provided
# with GATB-Core. (This file is located next to this snippet)
F_NAME='../thirdparty/gatb-core/gatb-core/test/db/celegans_reads.h5'

# We create the graph
graph = Graph('-in %s' % F_NAME)

# We iterate over some nodes
for i, node in enumerate(graph):
    print('{}: {!r}'.format(i, node))
    if i > 10: break
