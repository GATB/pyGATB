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

# We will use an album file: it only lists files containing
# sequences. An album is a very convenient way to provide
# GATB-Core with set of files.
F_NAME='../thirdparty/gatb-core/gatb-core/test/db/album.txt'

# We create the bank representation of the Album file
bank=Bank(F_NAME)

print ("Bank File: '%s'" % bank.uri)
print ("Bank Type: '%s'" % bank.type)
print ("Sub-banks: %d" % bank.albums)
print ("Estimated sequences in all files: %d" % bank.estimateNbSequences)
print ("Estimated letters in all files: %d" % bank.estimateNbLetters)

# We iterate over some sequences. Bank handles for us the fact that
# we actually process several sequence files.
for i, seq in enumerate(bank):
  # 'seq' is of type 'Sequence'.
  # Accessing 'Sequence' internals is done as follows:
  #   sequence header : seq.comment
  #   sequence quality: seq.quality (Fastq only)
  #   sequence letters: seq.sequence
  #   sequence size   : len(seq)
  seqid=seq.comment.decode("utf-8").split(" ")[0]
  print('%d: %s: %d letters' % (i, seqid, len(seq)))

