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
from libcpp.vector cimport vector

from libcpp cimport bool
from libc.stdint cimport *



cdef extern from "gatb/system/api/ISmartPointer.hpp" namespace "gatb::core::system":
    cdef cppclass ISmartPointer:
        void use()
        void forget()

    cdef cppclass SmartPointer(ISmartPointer):
        pass

    # TODO: SmartObject, LocalObject


cdef extern from "gatb/tools/designpattern/api/Iterator.hpp" namespace "gatb::core::tools::dp":
    cdef cppclass Iterator[Item](SmartPointer):
        Iterator()
        void first()
        void next()
        bool isDone()
        Item & item()
        #iterate[Functor](Functor &f)
        setItem(Item &i)
        bool get(vector[Item] &current)
        reset()
        finalize()
        #vector[Iterator[Item]*] getComposition()

    cdef cppclass ISmartIterator[T](Iterator[T]):
        uint64_t size()
        uint64_t rank()


cdef extern from "gatb/tools/collections/api/Iterable.hpp" namespace "gatb::core::tools::collections":
    cdef cppclass Iterable[Item](ISmartPointer):
        Iterator[Item]* iterator()
        #iterate[Functor](Functor f)
        int64_t getNbItems()
        int64_t estimateNbItems()
        Item * getItems(Item *&buffer)
        size_t getItems(Item *&buffer, size_t start, size_t nb)

    cdef cppclass Bag[Item](ISmartPointer):
        insert(const Item &item)
        insert(const vector[Item] &items, size_t length=0)
        insert(const Item *items, size_t length)
        flush()


cdef extern from "gatb/tools/misc/api/Vector.hpp" namespace "gatb::core::tools::misc":
    cdef cppclass Vector[T](SmartPointer):
        Vector()
        Vector(size_t aSize)
        Vector& operator=(const Vector &vect)
        char * getBuffer() const
        size_t size() const
        T & operator[](size_t idx)
        resize(size_t aSize)
        setSize(size_t size)
        setRef(Vector *ref, size_t offset, size_t length)
        setRef(T *buffer, size_t length)
        set(T *buffer, size_t length)

cdef extern from "gatb/tools/misc/api/Data.hpp" namespace "gatb::core::tools::misc":
    cdef cppclass Data(Vector[char]):
        enum Encoding_e:
            ASCII, INTEGER, BINARY
        Data(Encoding_e)
        Data(char *buffer)
        Data(size_t, Encoding_e)
        Data& operator=(const Data &d)
        setRef(Data *, size_t offset, size_t length)
        Encoding_e getEncoding()
        setEncoding(Encoding_e encoding)

#cdef extern from "gatb/tools/misc/Data.hpp" namespace "gatb::core::tools::misc::Data":
#    convert(&Data in, &Data out)
