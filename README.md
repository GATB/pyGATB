# About pyGATB

This is an experimental python wrapper for the GATB-CORE library.

The architecture of the tool is as follows:


# License

Please not that GATB-Core is distributed under Affero-GPL license.

# Install pyGATB

pyGATB is a binary python extension module. In the future, binary distribution will be distributed for Linux and macOS.

In the meantime you can try [prebuilt docker images with Jupyter notebook](docker/).

# How to build pyGATB

## Dependencies

The following third parties should be already installed:

* a C++/11 compiler (*e.g.* GCC 4.7+, Clang 3.5+, Apple/Clang 6+)
* [CMake 3.1.0+](http://cmake.org/download) (mandatory)
* [Python 3.3+](https://www.python.org/ftp/python/3.4.5/Python-3.4.5.tgz) (mandatory)
* [Cython 0.25](https://pypi.python.org/pypi/Cython/) (mandatory)
* Python's setuptools >= 0.6b1
* python-igraph (optional, for plotting BFS trees)



We suppose that your system (Linux or OSX) does not provide you with Python3 and Cython. So let us do that installation first.

**Note:** install procedures experimented on OSX system; should be quite similar on a Linux system.

### Install Python3

**Note:** depending on the way you install Python3, you will not build pyGATB the same way. Since we have tested both solutions, we provide you with our experience... ;-)

#### Install Python3 - From package installer

Run Python installer from [its official package installer](https://www.python.org/ftp/python/3.4.4/python-3.4.4-macosx10.6.pkg).

Using Python3 package installer places the interpreter files in a place that is not fully appropriate for CMake: you'll have to add some information on the CMake command-line (see section called "build pyGATB on OSX", below).

#### Install Python3 - From sources

```bash 
curl -O https://www.python.org/ftp/python/3.4.5/Python-3.4.5.tgz
tar -Zxf Python-3.4.5.tgz
cd Python-3.4.5
./configure
make -j8 test
sudo make install
python3 --version
cd ..
sudo rm -rf Python-3.4.5*
```

Installing Python3 from its sources places the interpreter in a very appropriate way for CMake: you'll see below that the CMake command-line is very simple.

#### Install Python3: Ubuntu and debian

When installing Python3 on Linux, do not forget to install both Python3 (the interpreter itself) and Python3-dev (the development package, required by Cython).

Example of installation on Debian/Jessie:

```bash 
sudo apt-get install python3.4 python3.4-dev python3-setuptools
```

### Install Cython

Requirement: Python3 has to be installed BEFORE installing Cython.

Install Cython **from its source**, as follows:

* download ```Cython-0.25.2.tar.gz``` from [https://pypi.python.org/pypi/Cython/](https://pypi.python.org/pypi/Cython/)
* gunzip/untar the content of the Cython archive
* enter directory ```Cython-0.25.2``` and type: 

```bash
# if you have root priviliges:
python3 setup.py install

#... otherwise:
sudo python3 setup.py install
```
* On some installations, symlink for cython was not created. So check that:

```bash
cython

# cython ok?
```

if your OSX installation fails to run cython, then:

```bash
cd /usr/local/bin/
sudo ln -s /Library/Frameworks/Python.framework/Versions/3.4/bin/cython cython
```

## Build pyGATB on Linux

For building your project, you should do the following
   
```bash 
# Get a frech copy of pyGATB
git clone --recursive https://github.com/GATB/pyGATB

# Prepare build directory
cd pyGATB && mkdir build && cd build

# Prepare build environment
cmake . .. -DCMAKE_BUILD_TYPE=Release

# --> Carefully check that CMake has located Cython and Python3

# ok... then: build pyGATB
make -j8

# Run test
python3 setup.py test

# test ok?
# then:
python3 setup.py install --user
```

Then, the demo notebook can be opened with:
```bash
cd ../doc; 
jupyter-notebook demo.ipynb
```

## Build pyGATB on OSX

### If you have installed Python3 using an installer:

```bash 
# Get a frech copy of pyGATB
git clone --recursive https://github.com/GATB/pyGATB

# Prepare build directory
cd pyGATB && mkdir build && cd build

# Prepare build environment
cmake . .. -DCMAKE_BUILD_TYPE=Release

# Python3 installer put Python3 in a place that is not 
# convenient for CMake... so we have to specify where are
# located Python3 libs and includes
cmake . .. -DCMAKE_BUILD_TYPE=Release \
-DPYTHON_LIBRARY="/Library/Frameworks/Python.framework/Versions/3.4/lib/libpython3.4.dylib" \
-DPYTHON_INCLUDE_DIR="/Library/Frameworks/Python.framework/Versions/3.4/include/python3.4m"

# --> Carefully check that CMake has located Cython and Python3

# ok... then: build pyGATB
make -j8

# Run test
python3 setup.py test

# test ok?
# then:
python3 setup.py install --user
```

### If you have installed Python3 from its sources:

```bash 
# Get a frech copy of pyGATB
git clone --recursive https://github.com/GATB/pyGATB

# Prepare build directory
cd pyGATB && mkdir build && cd build

# Prepare build environment
cmake . .. -DCMAKE_BUILD_TYPE=Release

# --> Carefully check that CMake has located Cython and Python3

# ok... then: build pyGATB
make -j8

# Run test
python3 setup.py test

# test ok?
# then:
python3 setup.py install --user
```

# Make a test

After building pyGATB:

```bash 
cd pyGATB/samples
python3 read_h5.py
```

You should see this:

```bash 
File size: 652 kb
0: <Node k5 AAAAC F>
1: <Node k5 AAAAT F>
2: <Node k5 AAAAG F>
3: <Node k5 AAACA F>
4: <Node k5 AAACC F>
5: <Node k5 AAACT F>
6: <Node k5 AAACG F>
7: <Node k5 AAATA F>
8: <Node k5 AAATC F>
9: <Node k5 AAATT F>
10: <Node k5 AAATG F>
11: <Node k5 AAAGA F>
```

