#About pyGATB

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

#License

Please not that GATB-Core is distributed under Affero-GPL license.

#Dependencies

The following third parties should be already installed:

* CMake 3.1.0+ (mandatory)
* Python 3.3+ (mandatory)
* Python's setuptools >= 0.6b1
* python-igraph (optional, for plotting BFS trees)

#Project build

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





