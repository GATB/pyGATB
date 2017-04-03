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
        string getComment()
        string getQuality()
        char* getDataBuffer()
        size_t getDataSize()
        Data.Encoding_e getDataEncoding()
        size_t getIndex()

cdef extern from "gatb/bank/api/IBank.hpp" namespace "gatb::core::bank":
    cdef cppclass IBank(Iterable[Sequence], Bag[Sequence], ISmartPointer):
        size_t getCompositionNb()
        uint64_t estimateSequencesSize()

cdef extern from "gatb/bank/impl/Bank.hpp" namespace "gatb::core::bank::impl":
    cdef cppclass Bank:
        @staticmethod
        IBank* open(const string &uri)
        @staticmethod
        string getType(const string &uri)
