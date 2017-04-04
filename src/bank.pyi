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
cimport c_bank
cimport c_tools

from c_bank cimport Bank as cBank
from c_tools cimport Data as cData
from libcpp cimport *


cdef class Bank:
    cdef c_bank.IBank* thisptr
    cdef str uri
    def __cinit__(self, str uri):
        self.uri = uri
        self.thisptr = cBank.open(uri.encode('ascii'))

    def __dealloc__(self):
        if self.thisptr is not NULL:
            self.thisptr.forget()

    def __iter__(self):
        """
        Provide an iterator over the sequences contained in this bank.
        """
        cdef SequenceIterator it = SequenceIterator()
        cdef c_tools.Iterator[c_bank.Sequence]* cit = self.thisptr.iterator()
        it.thisptr = cit
        it.thisptr.first()
        return it

    property type:
        """
        Provide the bank type: album, fasta or fastq.
        """
        def __get__(self):
            return c_bank.Bank.getType(self.uri.encode('ascii')).decode('ascii')

    property albums:
        """
        Provide the number of banks contained in an album. This method always returns
        1 for single-based Fasta. 
        or Fastq bank file
        """
        def __get__(self):
            return self.thisptr.getCompositionNb()
    
    property uri:
        """
        Provide the URI from which this bank has been loaded.
        """
        def __get__(self):
            return self.uri;
    
    property estimateNbSequences:
        """
        Provide an estimation of the number of sequences contained in a bank.
        Estimation is made by computing a basic ratio from the first 5000 sequences
        contained in the bank. This value is of interest only for huge sequence file.
        """
        def __get__(self):
            return self.thisptr.estimateNbItems()
    
    property estimateNbLetters:
        """
        Provide an estimation of the number of sequence letters contained in a bank.
        Estimation is made by computing a basic ratio from the first 5000 sequences
        contained in the bank. This value is of interest only for huge sequence file.
        """
        def __get__(self):
            return self.thisptr.estimateSequencesSize()

    def __repr__(self):
        return '<%s %s %r>' % (Bank.__qualname__, self.type.title(), self.uri)



cdef class SequenceIterator:
    cdef c_tools.Iterator[c_bank.Sequence]* thisptr
    def __dealloc__(self):
        if self.thisptr is not NULL:
            self.thisptr.forget()

    def __next__(self):
        if self.thisptr.isDone():
            raise StopIteration()
        else:
            self.thisptr.next()
            return Sequence.fromCpp(self.thisptr.item())
            
    def __iter__(self):
      return self

cdef class Sequence:
    cdef public bytes comment, quality, sequence
    cdef public size_t index
    cdef bool owned

    def __cinit__(self):
        #FIXME: what about zero initialization ?
        assert self.owned == False

    def __init__(self):
        raise TypeError('Sequence cannot be instantiated from Python')

    @staticmethod
    cdef fromCpp(c_bank.Sequence &cseq):
        cdef Sequence seq = Sequence.__new__(Sequence)
        if cseq.getDataEncoding() != 0: #cData.Encoding_e.ASCII:
            raise NotImplemented('Only ascii sequences are supported')
        seq.sequence = cseq.getDataBuffer()[:cseq.getDataSize()]
        seq.index = cseq.getIndex()
        seq.comment = cseq.getComment()
        seq.quality = cseq.getQuality()
        return seq

    def __len__(self):
        return len(self.sequence)

    def __bytes__(self):
        return self.sequence

