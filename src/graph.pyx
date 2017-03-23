#cython: language_level=3, always_allow_keywords=False, cdivision=True, embedsignature=True, wraparound=False, boundscheck=False

from libcpp cimport *
from libcpp.string cimport *
from libc.stdint cimport *

cimport cython
cimport cpython.tuple as ctuple
from cpython cimport ref

cimport c_graph
cimport c_tools


ctypedef fused anystring:
    bytes
    str

cdef list graphStates = ['INIT_DONE',
                         'CONFIGURATION_DONE',
                         'SORTING_COUNT_DONE',
                         'BLOOM_DONE',
                         'DEBLOOM_DONE',
                         'BRANCHING_DONE',
                         'MPHF_DONE',
                         'ADJACENCY_DONE',
                         'NONSIMPLE_CACHE']


cdef class Graph:
    """
    A classic GATB graph.
    Nodes objects obtained by iteration contain the actual API
    """
    cdef c_graph.Graph graph

    def __cinit__(self, str uri):
        self.graph = c_graph.Graph.create(uri.encode('ascii'))

    def __iter__(self):
        "Iterates over branching nodes."
        #BUG: why do we skip the first kmer ?
        return NodeIterator.create(unwrapBN(self.graph.iteratorBranching()), self)

    def nodes(self):
        "Iterates over all nodes."
        return NodeIterator.create(unwrapN(self.graph.iterator()), self)

    def __contains__(self, Node node):
        """Checks if the neighbor of a real node is in the graph
        eg: ``graph[bytes(node)[1:] + b'A'] in graph`` tests if the
        right extension with 'A' is present in the graph.
        False positives happen when the made up Node is further appart than
        one edge to a real Node.
        """
        return self.graph.contains(node.node)

    def __getitem__(self, object kmer):
        """Construct a Node from a k-mer in bytes
        Warning: as usual, don't get off track !
        """
        cdef bytes kmer_bytes
        if type(kmer) is str:
            kmer_bytes = kmer.encode('ascii')
        elif type(kmer) is bytes:
            kmer_bytes = kmer
        else:
            raise TypeError('Expected bytes or str.')
        if len(kmer_bytes) != self.graph.getKmerSize():
            raise ValueError("len('%s') != %d" % (kmer_bytes.decode('ascii'),
                                                  self.graph.getKmerSize()))
        return Node.create(self.graph.buildNode(kmer_bytes), self)

    def kmers(self, anystring s):
        #TODO: not implemented
        pass

    cdef size_t span(self):
        return self.graph.getKmerSize()

    property kmerSize:
        def __get__(self):
            return self.span()

    property state:
        def __get__(self):
            cdef list flags = []
            cdef uint64_t state = self.graph.getState()
            cdef uint64_t i
            for i, flag in enumerate(graphStates):
                if (1 << i) & state:
                    flags.append(flag)
                return flags

    def __repr__(self):
        return '<Graph k%d %s>' % (self.graph.getKmerSize(), ', '.join(self.state))


# Unwrap GraphIterators to get the inner ISmartIterator:
ctypedef c_tools.ISmartIterator[c_graph.Node] cNodeIterator
cdef inline cNodeIterator* unwrapN(c_graph.GraphIterator[c_graph.Node]&& it):
    cdef cNodeIterator* uit = it.get()
    uit.use()
    return uit

cdef inline cNodeIterator* unwrapBN(c_graph.GraphIterator[c_graph.BranchingNode]&& it):
    cdef cNodeIterator* uit = <cNodeIterator*> it.get()
    uit.use()
    return uit

cdef class NodeIterator:
    cdef cNodeIterator* thisptr
    cdef Graph graph

    @staticmethod
    cdef inline NodeIterator create(cNodeIterator* thisptr, Graph graph):
        cdef NodeIterator it = NodeIterator()
        thisptr.first()
        it.thisptr = thisptr
        it.graph = graph
        return it

    def __dealloc__(self):
        if self.thisptr is not NULL:
            self.thisptr.forget()

    def __iter__(self):
        return self

    def __next__(self):
        if self.thisptr.isDone():
            raise StopIteration()
        else:
            self.thisptr.next()
            # Copy the Node in a python wrapper :
            return Node.create(self.thisptr.item(), self.graph)

from cpython cimport object

@cython.freelist(256)
cdef class Node:
    # The graph::impl::Node, inlined
    cdef c_graph.Node node
    cdef Graph graph # Reference on Graph's wrapper object: for RC and API

    @staticmethod
    cdef inline Node create(const c_graph.Node& node, Graph graph):
        # Cython insist of using PyObjectCall, that's a bug.
        cdef Node n = (<object.PyTypeObject*>Node).tp_new(Node, (), ())
        n.node = node
        n.graph = graph
        return n

    def __copy__(Node self):
        cdef Node n = Node.create(self.node, self.graph)
        return n

    cdef inline string toString(self):
        return self.graph.graph.toString(<c_graph.Node>self.node)

    def __bytes__(self):
        return self.toString()

    def __str__(self):
        return self.toString().decode('ascii')

    cdef inline size_t length(self):
        return self.graph.span()

    def __len__(self):
        return self.length()

    def __iter__(self):
        "iterates nucleotides"
        cdef string s = self.toString()
        for i in range(self.length()):
            yield s.at(i)

    def __getitem__(self, int i):
        if not 0 <= i < self.length():
            return self.graph.graph.getNT(self.node, i)

    def __repr__(self):
        return '<Node k%d %s %s>' % (len(self), self, [' ', 'F', 'R', 'A'][self.node.strand])

    def __richcmp__(Node self, Node other, int op):
        if op == 0:
            return self.node.kmer < other.node.kmer
        elif op == 1:
            return self.node.kmer <= other.node.kmer
        elif op == 2:
            return self.node.kmer == other.node.kmer
        elif op == 3:
            return self.node.kmer != other.node.kmer
        elif op == 4:
            return other.node.kmer < self.node.kmer
        elif op == 5:
            return other.node.kmer <= self.node.kmer

    def __hash__(self):
        return c_graph.hash1(self.node.kmer, 0)

    property strand:
        def __get__(self):
            return <int> self.node.strand

    cpdef void reverse(self):
        "In-place reverse complement"
        self.node.strand = c_graph.StrandReverse(self.node.strand)

    property reversed:
        "Returns the reverse complement (as a copy)"
        def __get__(self):
            cdef Node n = Node.create(self.node, self.graph)
            n.reverse()
            return n

    cdef inline size_t degree(self, c_graph.Direction direction):
        return self.graph.graph.degree(self.node, direction)

    property out_degree:
        def __get__(self):
            return self.degree(c_graph.DIR_OUTCOMING)

    property in_degree:
        def __get__(self):
            return self.degree(c_graph.DIR_INCOMING)

    property degree:
        def __get__(self):
            return self.degree(c_graph.DIR_END)

    cdef inline tuple neighbors(self, c_graph.Direction direction):
        cdef c_graph.Nodes nodes = self.graph.graph.neighbors(self.node, direction)
        cdef size_t n = nodes.size()
        cdef tuple pynodes = ctuple.PyTuple_New(n)
        cdef Node tmp
        for i in range(n):
            tmp = Node.create(nodes[i], self.graph)
            ref.Py_INCREF(tmp)
            ctuple.PyTuple_SET_ITEM(pynodes, i, tmp)
        return pynodes

    property succs:
        "Succesors"
        def __get__(self):
            return self.neighbors(c_graph.DIR_OUTCOMING)

    property preds:
        "Predecessors"
        def __get__(self):
            return self.neighbors(c_graph.DIR_INCOMING)

    property neighbors:
        def __get__(self):
            return self.neighbors(c_graph.DIR_END)

    property paths:
        "Simple paths from this node"
        def __get__(self):
            return simplePathsTuple(self, c_graph.DIR_OUTCOMING)

    property paths_backward:
        "Simple path to this node in backward direction"
        def __get__(self):
            return simplePathsTuple(self, c_graph.DIR_INCOMING)

    property abundance:
        def __get__(self):
            return self.graph.graph.queryAbundance(self.node)

    property state:
        def __get__(self):
            return self.graph.graph.queryNodeState(self.node)
        def __set__(self, int state):
            self.graph.graph.setNodeState(self.node, state)


# TODO: provide interface to Traversals
cdef inline tuple simplePathsTuple(Node origin_node, c_graph.Direction direction):
    cdef const c_graph.Graph* graph
    cdef c_graph.Direction reverse
    cdef c_graph.Edges directneighbors
    cdef size_t ndirectneighbors
    cdef object res
    cdef object resitem = None

    cdef c_graph.Edges neighbors
    cdef size_t nneighbors
    cdef c_graph.Node last_node
    cdef string path
    cdef int stop_reason

    with nogil:
        graph = &origin_node.graph.graph
        reverse = c_graph.reverse(direction)

        directneighbors = graph.neighborsEdge(origin_node.node, direction)
        ndirectneighbors = directneighbors.size()

    res = ctuple.PyTuple_New(ndirectneighbors)

    with nogil:
        for i in range(ndirectneighbors):
            path.clear()
            path.push_back(c_graph.ascii(directneighbors[i].nt))

            # Current Node
            last_node = directneighbors[i].to_node

            while True: # Path loop
                # Checks that current node has only one predecessor in the path
                if graph.degree(last_node, reverse) > 1:
                    stop_reason = c_graph.Direction.DIR_INCOMING
                    break

                # Path lookahead
                neighbors = graph.neighborsEdge(last_node, direction)
                nneighbors = neighbors.size()

                if nneighbors != 1: # Multiple or no successors in the path
                    if nneighbors == 0:
                        stop_reason = c_graph.Direction.DIR_END
                    else:
                        stop_reason = c_graph.Direction.DIR_OUTCOMING
                    break

                # Path advance
                last_node = neighbors[0].to_node
                path.push_back(c_graph.ascii(neighbors[0].nt))

            with gil: # TODO: lift python object creation pass out of loop
                resitem = (path, Node.create(last_node, origin_node.graph), stop_reason)
                ref.Py_INCREF(resitem)
                ctuple.PyTuple_SET_ITEM(res, i, resitem)

    return res
