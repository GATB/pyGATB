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

    def aux_load_readset(self, readset, expected_type):
        "Loads a bank, tests some invariants, and return the number of sequence"
        readset_fpath = self.get_db_path(readset)
        bank = core.Bank(readset_fpath)

        self.assertIsInstance(bank, core.Bank)
        self.assertEqual(bank.type, expected_type)

        it = iter(bank)
        self.assertIsInstance(it, core.SequenceIterator)

        sequences = list(it)
        self.assertIsInstance(sequences[0], core.Sequence)

        return len(set(sequences))

    def test_album(self):
        # Load the album
        album_reads_count = self.aux_load_readset(self.album_name, 'album')

        # Load each read set and count the total number of read
        read_count = 0
        with open(self.get_db_path(self.album_name)) as album_readsets:
            for readset in album_readsets:
                read_count += self.aux_load_readset(readset.rstrip(), 'fasta')

        self.assertEqual(album_reads_count, read_count)

    def test_fasta_gzip(self):
        self.assertEqual(self.aux_load_readset('reads3.fa.gz', 'fasta'), 5000)

    def test_fastaq_gzip(self):
        bank = core.Bank(self.get_db_path('sample.fastq.gz'))
        for sequence in bank:
            self.assertIsInstance(sequence, core.Sequence)
            self.assertEqual(len(sequence.sequence), len(sequence.quality))

    def test_estimateNbSequences(self):
        from tempfile import NamedTemporaryFile

        nrepeats = 256 # Number of times we repeat sample1.fa in the album
        sample1_path  = self.get_db_path('sample1.fa')

        album_tmpfile = NamedTemporaryFile('w+t', encoding='ascii', suffix='.txt')
        album_tmpfile.writelines([sample1_path + '\n'] * nrepeats)
        album_tmpfile.flush()

        bank = core.Bank(sample1_path)
        album_bank = core.Bank(album_tmpfile.name)

        self.assertEqual(
            bank.estimateNbSequences * nrepeats,
            album_bank.estimateNbSequences
        )

        self.assertEqual(
            bank.estimateNbLetters * nrepeats,
            album_bank.estimateNbLetters
        )

        album_tmpfile.close()

    def test_eq(self):
        bank = core.Bank(self.get_db_path('sample.fastq.gz'))
        it = iter(bank)
        s1 = next(it)
        s2 = next(it)

        self.assertEqual(s1, s1)
        self.assertEqual(s2, s2)
        self.assertNotEqual(s1, s2)
        self.assertEqual(len(set([s1,s2]*2)), 2)
