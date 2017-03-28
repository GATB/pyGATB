# ===========================================================================
#   pyGATB : Python3 wrapper for GATB-Core
#   Copyright (C) 2017 INRIA
#   Author: Patrick G. Durand
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

# we import pyGATB Bank
from gatb import Bank

# We will use a file containing some Fasta sequences
F_NAME='../thirdparty/gatb-core/gatb-core/test/db/query.fa'

# We create the bank representation of the Fasta sequence file
bank=Bank(F_NAME)

print ("File '%s' is of type: %s"% (bank.uri, bank.type))

nseqs=0

# We iterate over some sequences.
for i, seq in enumerate(bank):
  # 'seq' is of type 'Sequence'.
  # Accessing 'Sequence' internals is done as follows:
  #   sequence header : seq.comment
  #   sequence quality: seq.quality (Fastq only)
  #   sequence letters: seq.sequence
  #   sequence size   : len(seq)
  seqid=seq.comment.decode("utf-8").split(" ")[0]
  if i<5:
    print('%d: %s: %d letters' % (i, seqid, len(seq)))
  nseqs+=1  

print('#sequences: %d' % nseqs)
