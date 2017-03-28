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
from . import TestCaseWithDB
from .. import core

class TestGraph(TestCaseWithDB):
    h5relpath = 'celegans_reads.h5'
    expected_kmerSize = 5
    expected_branching_nodes = 356
    expected_nodes = 356

    def setUp(self):
        self.h5path = self.get_db_path(self.h5relpath)
        print('-in %s' % self.h5path)
        self.g = core.Graph('-in %s' % self.h5path)

    def test_kmerSize(self):
        self.assertEqual(self.g.kmerSize, self.expected_kmerSize)

    def aux_test_iterator(self, it, expected_len):
        self.assertIsInstance(it, core.NodeIterator)
        l = list(it)
        self.assertEqual(len(l), expected_len)

        node = l[0]
        self.assertIsInstance(node, core.Node)
        self.assertEqual(len(node), self.expected_kmerSize)

    def test_listbranching(self):
        self.aux_test_iterator(iter(self.g), self.expected_branching_nodes)

    def test_listnodes(self):
        self.aux_test_iterator(self.g.nodes(), self.expected_nodes)

