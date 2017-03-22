# About pyGATB

This is an experimental python wrapper for the GATB-CORE library.

The architecture of the tool is as follows:

* a CMakeLists.txt file used for building the project
* a 'tools' directory holding a default source code using GATB-Core
* a 'scripts' directory holding a script to automatically package the tool
* a 'thirdparty' directory holding the gatb-core resources
* a 'doc' directory, contains a Jupyter notebook demo
* a 'tests' directory holding test procedures
    
The 'thirdparty' directory is only available for tool created outside the GATB-Tools repository.
Tools located within GATB-Tools rely on a common GATB-Core sub-module already available in this repository.

# License

Please not that GATB-Core is distributed under Affero-GPL license.

# Dependencies

The following third parties should be already installed:

* a C++/11 compiler (*e.g.* GCC 4.7+, Clang 3.5+, Apple/Clang 6+)
* [CMake 3.1.0+](http://cmake.org/download) (mandatory)
* [Python 3.3+](https://www.python.org/ftp/python/3.4.5/Python-3.4.5.tgz) (mandatory)
* [Cython 0.25](https://pypi.python.org/pypi/Cython/) (mandatory)
* Python's setuptools >= 0.6b1
* python-igraph (optional, for plotting BFS trees)

# Project build

## Linux

For building your project, you should do the following
   
```bash 
git clone --recursive https://github.com/Piezoid/pyGATB
cd pyGATB
mkdir build && cd build
cmake . .. -DCMAKE_BUILD_TYPE=Release
make -j8
python3 setup.py install --user
```

Then, the demo notebook can be opened with:
```bash
cd ../doc; 
jupyter-notebook demo.ipynb
```

## Mac OSX

OSX is usually shipped with Python 2.7. However, to compile pyGATB you need a Python 3.3+.

So, first of all, install Python from [its official package installer](https://www.python.org/ftp/python/3.4.4/python-3.4.4-macosx10.6.pkg).

Then, install Cython **from its source**:

* download ```Cython-0.25.2.tar.gz``` from [https://pypi.python.org/pypi/Cython/](https://pypi.python.org/pypi/Cython/)
* gunzip/untar the content of the Cython archive
* enter directory ```Cython-0.25.2``` and type: 

```bash
python3 setup.py install
```
* finally, create a symlink for cython, as follows:

```bash
cd /usr/local/bin/
sudo ln -s /Library/Frameworks/Python.framework/Versions/3.4/bin/cython cython
```

You are now ready to compile pyGATB:

```bash 
git clone --recursive https://github.com/Piezoid/pyGATB
cd pyGATB
mkdir build && cd build
cmake . .. -DCMAKE_BUILD_TYPE=Release \
-DPYTHON_LIBRARY="/Library/Frameworks/Python.framework/Versions/3.4/lib/libpython3.4.dylib" \
-DPYTHON_INCLUDE_DIR="/Library/Frameworks/Python.framework/Versions/3.4/include/python3.4m"
make -j8
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

