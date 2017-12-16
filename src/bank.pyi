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
cimport cython
cimport c_bank
cimport c_tools

from c_bank cimport Bank as cBank
from c_tools cimport Data as cData
from libcpp cimport *
from posix.unistd cimport access, F_OK


cdef class Bank:
    cdef c_bank.IBank* thisptr
    cdef str uri
    def __cinit__(self, str uri):
        if access(uri.encode('ascii'), F_OK) != 0:
            raise FileNotFoundError
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
        cdef Sequence seq
        if self.thisptr.isDone():
            raise StopIteration()
        else:
            seq = Sequence.fromCpp(self.thisptr.item())
            self.thisptr.next()
            return seq
            
    def __iter__(self):
      return self

@cython.freelist(256)
cdef class Sequence:
    cdef public bytes comment, quality, sequence
    cdef public size_t index
    cdef bool owned

    def __cinit__(Sequence self):
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

    def __len__(Sequence self):
        return len(self.sequence)

    def __bytes__(Sequence self):
        return self.sequence

    def __str__(Sequence self):
        return self.sequence.decode('ascii')

    def __repr__(Sequence self):
        return '<Sequence %d %r len=%d>' % (self.index, self.comment.decode('ascii'), len(self))

    cdef bool __iseq(Sequence self, Sequence other):
        return self is other \
            or other.sequence == self.sequence \
           and other.quality== self.quality \
           and other.comment == self.comment

    cdef bool __isless(Sequence self, Sequence other):
        if self is other:
            return False
        elif self.sequence != other.sequence:
            return self.sequence < other.sequence
        elif self.quality != other.quality:
            return self.quality < other.quality
        else:
            return self.comment < other.comment

    def __richcmp__(Sequence self, Sequence other, int op):
        if op & 2: # == or !=
            return self.__iseq(other) != ((op & 1) != 0) # Xor flip for !=
        else: # >, >=, < or <=
            return ( other.__isless(self) if op == 4 or op == 1 # Swap order for > or <=
                     else self.__isless(other) ) \
                   != ((op & 1) != 0) # Xor flip for <= or >=

    def __hash__(Sequence self):
        return hash((self.comment, self.sequence, self.quality))

