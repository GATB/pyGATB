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
from unittest import TestCase
from importlib import reload, import_module

class TestBank(TestCase):
    "Checks package structure"
    def setUp(self):
        # Get parent package
        self.gatb = import_module('..', __package__)

    def test_package_name(self):
        self.assertIn(__package__.partition('.')[0], ('src', 'gatb'))

    def test_reload(self):
        "Try to reload gatb (the parent package). This allows to catch warnings with pytest-warnings."
        reload(self.gatb)

    def test_version(self):
        self.assertIsInstance(self.gatb.__version__, str)

    def aux_test_module_content(self, module, expected_content):
        symbols = {symbol for symbol in dir(module)
                   if not symbol.startswith('__')}
        self.assertFalse(symbols.symmetric_difference(expected_content))

    def test_gatb_content(self):
        self.aux_test_module_content(self.gatb, {
            'Bank',
            'Graph',
            'core',
            'tests',
        })

    def test_core_content(self):
        self.aux_test_module_content(self.gatb.core, {
            'Bank',
            'Sequence',
            'SequenceIterator',

            'Graph',
            'Node',
            'NodeIterator',
            })
