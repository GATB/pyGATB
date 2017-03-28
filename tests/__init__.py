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
import unittest
import os

class TestCaseWithDB(unittest.TestCase):
    test_dir = os.path.dirname(os.path.abspath(__file__))
    db_dir = os.path.join(test_dir, 'db')
    def get_db_path(self, name):
        fpath = os.path.join(self.db_dir, name)
        self.assertTrue(os.path.exists(fpath), msg='%r file not found in test data db' % name)
        return fpath

    def test_000_have_db(self):
        self.assertTrue(os.path.isdir(self.db_dir), msg='test data db not found: %r' % os.path.abspath(self.db_dir))
