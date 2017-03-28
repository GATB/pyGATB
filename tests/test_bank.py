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

class TestBank(TestCaseWithDB):
    album_name = 'album.txt'

    def test_album(self):
        # Load the album
        album_reads_count = self.aux_load_readset(self.album_name)

        # Load each read set and count the total number of read
        read_count = 0
        for readset in open(self.get_db_path(self.album_name)):
            read_count += self.aux_load_readset(readset.rstrip())

        self.assertEqual(album_reads_count, read_count)

    def aux_load_readset(self, readset):
        readset_fpath = self.get_db_path(readset)
        bank = core.Bank(readset_fpath)

        self.assertIsInstance(bank, core.Bank)

        it = iter(bank)
        self.assertIsInstance(it, core.SequenceIterator)

        sequences = list(it)
        self.assertIsInstance(sequences[0], core.Sequence)

        return len(sequences)

    def test_fasta_gzip(self):
        self.assertEqual(self.aux_load_readset('reads3.fa.gz'), 5000)

    def test_fastaq_gzip(self):
        bank = core.Bank(self.get_db_path('sample.fastq.gz'))
        for sequence in bank:
            self.assertIsInstance(sequence, core.Sequence)
            self.assertEqual(len(sequence.sequence), len(sequence.quality))
