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
from libcpp.string cimport string

from c_tools cimport *
from libc.stdint cimport *

cdef extern from "gatb/bank/api/Sequence.hpp" namespace "gatb::core::bank":
    cdef cppclass Sequence(Data):
        Sequence(Data.Encoding_e)
        string getComment()
        string getCommentShort()
        string getQuality()
        Data& getData()
        char* getDataBuffer()
        size_t getDataSize()
        Data.Encoding_e getDataEncoding()
        size_t getIndex()
        setDataRef(Data* ref, int offset, int length)
        setIndex(size_t)
        string toString()
        void setComment(string)
        void setQuality(string)




cdef extern from "gatb/bank/api/IBank.hpp" namespace "gatb::core::bank":
    cdef cppclass IBank(Iterable[Sequence], Bag[Sequence], ISmartPointer):
        string getId()
        string getIdNb(int i)
        int64_t estimateNbItemsBanki(int i)
        insert(const Sequence &item)
        size_t getCompositionNb()
        estimate(uint64_t &number, uint64_t &totalSize, uint64_t &maxSize)
        uint64_t estimateSequencesSize()
        uint64_t getEstimateThreshold()
        setEstimateThreshold(uint64_t nbSeq)
        remove()
        finalize()

cdef extern from "gatb/bank/impl/AbstractBank.hpp" namespace "gatb::core::bank":
    cdef cppclass AbstractBank(IBank, SmartPointer):
        pass

    cdef cppclass BankFasta(AbstractBank):
        BankFasta (const string &filename, bool output_fastq, bool output_gz)
        int64_t getNbItems ()
        estimate (uint64_t &number, uint64_t &totalSize, uint64_t &maxSize)

cdef extern from "gatb/bank/impl/Bank.hpp" namespace "gatb::core::bank::impl":
    cdef cppclass Bank:
        @staticmethod
        IBank* open(const string &uri)
        @staticmethod
        string getType(const string &uri)
        @staticmethod
        size_t getCompositionNb(const string &uri)
