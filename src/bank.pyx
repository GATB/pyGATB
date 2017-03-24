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


from enum import Enum

#from libcpp cimport *

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
        cdef SequenceIterator it = SequenceIterator()
        cdef c_tools.Iterator[c_bank.Sequence]* cit = self.thisptr.iterator()
        it.thisptr = cit
        it.thisptr.first()
        return it

    property type:
        def __get__(self):
            return c_bank.Bank.getType(self.uri.encode('ascii')).decode('ascii')

    property compositionNb:
        def __get__(self):
            return c_bank.Bank.getCompositionNb(self.uri.encode('ascii'))

    def __repr__(self):
        return '<%s %s %r>' % (Bank.__qualname__, self.type.title(), self.uri)



#cdef class FastaB ank(Bank):
    #def __init__(self, str filename, bool fasta_q):
        #pass

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

class Encoding(Enum):
    "Sequence encoding enum"
    ASCII = 0
    INTEGER = 1
    BINARY = 2

cdef class Sequence:
    cdef cData *data
    cdef public bytes comment, quality
    cdef public size_t index
    cdef bool owned

    def __cinit__(self):
        #FIXME: what about zero initialization ?
        assert self.owned == False

    def __init__(self):
        raise TypeError('Sequence cannot be instantiated from Python')

    @staticmethod
    cdef fromCpp(c_bank.Sequence &cseq, bool own=False):
        cdef Sequence seq = Sequence.__new__(Sequence)
        seq.data = &cseq.getData()
        seq.index = cseq.getIndex()
        seq.comment = cseq.getComment()
        seq.quality = cseq.getQuality()
        if own:
            seq.owned = True
            seq.data.use()
        return seq

    def __dealloc__(self):
        if self.owned:
            self.data.forget()

    def __len__(self):
        return self.data.size()

    property encoding:
        def __get__(self):
            return Encoding(self.data.getEncoding())
        #def __set__(self, enc):
            #cdef cData.Encoding_e c_enc
            #if isinstance(enc, int):
                #c_enc = enc
            #else:
                #c_enc = enc.value
            #self.thisptr.setEncoding(c_enc)

    def __bytes__(self):
        #return b''
        return self.data.getBuffer()[:self.data.size()]
        #return self.thisptr.toString()

