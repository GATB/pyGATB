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
from collections import deque
import igraph

colors = {
    'red': '#FF3C3C',
    'yellow': '#FFDE3C',
    'green': '#30CD30',
    'blue': '#5639B1',
    'gray': '#b3b3b3'
}
def bfs_igraph(root, max_depth=5, tree_layout=False, max_edge_label_length=4, plot=True, return_state=False):
    kmerSize = len(root)
    seen = {root: 0} # Map seen kmer to node id
    # Double buffered queue
    queue = deque([root])
    queue_next_depth = deque()
    depth = 0

    nodes = [root]
    node_colors = [colors['red']]
    edges = []
    elabels = []

    while True:
        while queue:
            pred = queue.popleft()
            pred_id = seen[pred]
            for path, succ, er in pred.paths:
                succ_id = seen.setdefault(succ, len(nodes))
                if succ_id == len(nodes):
                    if er == 2:
                        assert succ.in_degree > 1
                        if succ.out_degree > 1:
                            color = colors['green'] # Green: in and out-branching
                        else:
                            color = colors['yellow'] # Yellow: in-branching
                    elif er == 1:
                        assert succ.out_degree > 1
                        assert succ.in_degree == 1
                        color = colors['blue'] # Blue: out-branching
                    else:
                        assert succ.out_degree == 0
                        color = colors['gray']

                    nodes.append(succ)
                    node_colors.append(color)
                    if er != 3: queue_next_depth.append(succ)

                if len(path) <= max_edge_label_length:
                    elabel = path.decode('ascii')
                elif len(path) > kmerSize and len(path) <= kmerSize + max_edge_label_length:
                    elabel = '%s\u2026' % path[:-kmerSize].decode('ascii')
                else:
                    elabel = str(len(path))
                edges.append((pred_id, succ_id))
                elabels.append(elabel)

        assert not queue
        if depth >= max_depth:
            break
        queue, queue_next_depth = queue_next_depth, queue
        depth += 1

    print('%d nodes, %d edges.' % (len(nodes), len(edges)))
    G = igraph.Graph(len(nodes), directed=True, edges=edges)
    G.vs['color'] = node_colors
    G.vs['frame_color'] = '#00000000'
    G.vs.select(seen[node] for node in queue_next_depth)['frame_color'] = colors['red']
    G.es['label'] = elabels

    if plot:
        if tree_layout:
            layout = G.layout_reingold_tilford_circular(root=[0])
        else:
            layout = G.layout_kamada_kawai()
        G = igraph.plot(G, layout=layout,
                vertex_frame_width=0.75,
                vertex_size=5,
                edge_arrow_size=0.3,
                edge_width=0.5,
                edge_label_size=6,
                inline=True)

    if return_state:
        return G, queue_next_depth, seen
    else:
        return G
