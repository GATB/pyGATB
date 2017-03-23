from libcpp.string cimport string

from libcpp.vector cimport vector
from libcpp cimport *
from libc.stdint cimport *

from libcpp.complex cimport complex

cimport c_tools
from c_tools cimport Data


cdef extern from "gatb/tools/math/Integer.hpp" namespace "gatb::core::tools::math":
    cppclass Integer:
        bool operator<(Integer)
        bool operator<=(Integer)
        bool operator==(Integer)
        bool operator!=(Integer)
        bool operator>(Integer)
        bool operator>=(Integer)
        size_t getSize()
        const char* getName()

    uint64_t hash1"hash1"(const Integer&, uint64_t)

cdef extern from "gatb/kmer/api/IModel.hpp" namespace "gatb::core::kmer" nogil:
    enum KmerMode:
       KMER_DIRECT, KMER_REVCOMP, KMER_CANONICAL
    enum Strand:
        STRAND_FORWARD = (1<<0),
        STRAND_REVCOMP = (1<<1),
        STRAND_ALL = STRAND_FORWARD + STRAND_REVCOMP

    Strand StrandReverse(Strand)

    enum Nucleotide:
        NUCL_A = 0,
        NUCL_C = 1,
        NUCL_T = 2,
        NUCL_G = 3,
        NUCL_UNKNOWN = 4
    char ascii(Nucleotide)
    Nucleotide reverse(Nucleotide)


#cdef extern from "gatb/kmer/impl/Model.hpp" namespace "gatb::core::kmer":
    #cppclass Kmer[span]:
        #cppclass Type(complex):
            #pass


    #cppclass ModelAbstract[KmerKind, impl]:
        #ModelAbstract(size_t sizeKmer)
        #size_t getSpan()
        #size_t getMemorySize() const
        #size_t getKmerSize() const

        #cppclass Kmer:
            #cppclass Type(complex):
                #pass

        #ctypedef KmerKind.Type KmerDataType

        #KmerDataType& getKmerMax ()
        #string toString (KmerDataType &kmer)
        #string toString (uint64_t kmer)
        #KmerDataType reverse (const KmerDataType&)
        #KmerKind getKmer (Data &data, size_t startIndex)

        #KmerKind codeSeed (const char *seq, Data.Encoding_e encoding, size_t startIndex=0)

        #KmerKind codeSeedRight (const KmerKind &kmer, char nucl, Data.Encoding_e encoding)

        #bool build (Data &data, vector[KmerKind] &kmersBuffer)
        #void iterate[Callback](Data &data, Callback callback)
        #void iterateNeighbors[Functor] (KmerDataType &source, const Functor &fct, const bitset8 &mask) const
        #void iterateOutgoingNeighbors[Functor](KmerDataType &source, Functor &fct, const bitset4 &mask)
        #void iterateIncomingNeighbors[Functor] (KmerDataType &source, Functor &fct, const bitset4 &mask)

    #cppclass bitset8 "std::bitset<8>":
        #pass

    #cppclass bitset4 "std::bitset<4>":
        #pass


cdef extern from "gatb/debruijn/impl/Graph.hpp" namespace "gatb::core::debruijn::impl" nogil:
    enum Direction:
        DIR_OUTCOMING = 1,
        DIR_INCOMING = 2,
        DIR_END = 3

    Direction reverse(Direction)

    cppclass Node:
        Node()
        Node(Integer &kmer, Strand& strand)
        Integer kmer
        Strand strand

        bool operator==(Node)
        bool operator!=(Node)
        bool operator<(Node)

    cppclass BranchingNode "gatb::core::debruijn::impl::BranchingNode_t<gatb::core::debruijn::impl::Node>":
        pass

    cppclass Edge:
        Node from_node "from", to_node "to"
        Nucleotide nt
        Direction direction

        bool operator<(Edge)

    cppclass BranchingEdge "gatb::core::debruijn::impl::BranchingEdge_t<gatb::core::debruijn::impl::Node, gatb::core::debruijn::impl::Edge>":
        size_t distance

    cppclass Path:
        Node start
        vector[Nucleotide] path

        Path(size_t)
        Nucleotide& operator[](size_t)
        size_t size()
        void resize(size_t)
        void push_back(Nucleotide)
        void clear()
        char ascii(size_t)

    cppclass GraphVector[T]:
        T& operator[](size_t)
        size_t size()

    cppclass GraphIterator[T](c_tools.ISmartIterator[T]):
        # Get rid of the wrapper ASAP:
        c_tools.ISmartIterator[T]* get()

    cppclass Graph:
        # Graph State:
        enum StateMask:
            STATE_INIT_DONE           = (1<<0),
            STATE_CONFIGURATION_DONE  = (1<<1),
            STATE_SORTING_COUNT_DONE  = (1<<2),
            STATE_BLOOM_DONE          = (1<<3),
            STATE_DEBLOOM_DONE        = (1<<4),
            STATE_BRANCHING_DONE      = (1<<5),
            STATE_MPHF_DONE           = (1<<6),
            STATE_ADJACENCY_DONE      = (1<<7),
            STATE_NONSIMPLE_CACHE     = (1<<8)
        uint64_t getState()


        @staticmethod
        Graph load(string uri)
        @staticmethod
        Graph create(const char* uri)
        size_t getKmerSize()

        GraphIterator[Node] iterator()
        GraphIterator[BranchingNode] iteratorBranching()

        GraphVector[Node] neighbors(Node, Direction)
        GraphVector[Node] neighbors(Node.Value)
        GraphVector[Edge] neighborsEdge(Node, Direction)
        GraphVector[Edge] neighborsEdge(Node.Value)

        GraphVector[BranchingNode] neighborsBranching(Node, Direction)
        GraphVector[BranchingNode] neighborsBranching(Node.Value)
        GraphVector[BranchingEdge] neighborsBranchingEdge(Node, Direction)
        GraphVector[BranchingEdge] neighborsBranchingEdge(Node.Value)

        #GraphIterator[Node] getSimpleNodeIterator(Node, Direction)
        #GraphIterator[Edge] getSimpleEdgesIterator(Node, Direction)




        # Node Methods:
        bool contains(Node)
        size_t degree(Node, Direction)
        void degree(Node, size_t&, size_t)
        string toString(Node)
        bool isBranching(Node)
        Node buildNode(c_tools.Data*, size_t offset)
        Node buildNode(char*)
        BranchingNode reverse(BranchingNode)
        Nucleotide getNT(Node, size_t idx)
        int queryAbundance(Node)
        int queryNodeState(Node& node)
        void setNodeState(Node, int)
        void resetNodeState()
        void disableNodeState()

        unsigned long nodeMPHFIndex(Node)


        # Edges Methods:
        string toString(Edge)
        string toString(BranchingEdge)
        bool isSimple(Edge)









ctypedef GraphVector[Node] Nodes
ctypedef GraphVector[BranchingNode] BranchingNodes
ctypedef GraphVector[Edge] Edges
ctypedef GraphVector[BranchingEdge] BranchingEdges
