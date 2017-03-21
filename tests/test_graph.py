import unittest
from os import path

from src import graph

class TestCaseWithDB(unittest.TestCase):
    dbpath = 'tests/db/'
    def get_db_path(self, name):
        fpath = path.join(self.dbpath, name)
        self.assertTrue(path.exists(fpath), msg='%r file not found in test data db' % name)
        return fpath

    def test_000_have_db(self):
        self.assertTrue(path.isdir(self.dbpath), msg='test data db not found: %r' % path.abspath(self.dbpath))

class TestGraph(TestCaseWithDB):
    h5relpath = 'celegans_reads.h5'
    expected_kmerSize = 5
    expected_branching_nodes = 356
    expected_nodes = 356

    def setUp(self):
        self.h5path = self.get_db_path(self.h5relpath)
        self.g = graph.Graph(self.h5path)

    def test_kmerSize(self):
        self.assertEqual(self.g.kmerSize, self.expected_kmerSize)

    def aux_test_iterator(self, it, expected_len):
        self.assertIsInstance(it, graph.NodeIterator)
        l = list(it)
        self.assertEqual(len(l), expected_len)

        node = l[0]
        self.assertIsInstance(node, graph.Node)
        self.assertEqual(len(node), self.expected_kmerSize)

    def test_listbranching(self):
        self.aux_test_iterator(iter(self.g), self.expected_branching_nodes)

    def test_listnodes(self):
        self.aux_test_iterator(self.g.nodes(), self.expected_nodes)

