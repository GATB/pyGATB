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

* cmake 3.3+ (mandatory)
* python 3.4+ (mandatory)
* hdf5 (optional, gatb compiles its own otherwise)
* python-igraph (optional, for plotting BFS trees)

#Project build

For building your project, you should do the following
   
```bash 
git clone https://github.com/Piezoid/pyGATB
cd pyGATB
git submodule init
git submodule update
mkdir build && cd build
cmake . .. -DCMAKE_BUILD_TYPE=Release
make -j8
python setup.py install --user
```

Then to run the notebook :
```bash
cd ../doc; 
jupyter-notebook demo.ipynb
```





