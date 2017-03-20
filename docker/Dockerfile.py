#######################################################################################
#
# Dockerfile to start a GATB-Core/Ptyhon compiling machine using these dependencies:
#
#     -->  gcc 4.9 
#     -->  CMake 3.7.2
#     -->  Python 3.4
#     --> Cython 0.25
#
#   See below to change these values.
#
#--------------------------------------------------------------------------------------
#
# Use:
#
# ### To build the container, use: 
#  
#     docker build -f Dockerfile.py -t py_gatb_machine .
#
# ### To run the container.
#
#   Running the container means that you want to compile GATB-Core. For that 
#   purpose, docker run expects some information, as illustrated in this
#   command:
# 
#   docker run \
#     -i -t \
#     -e "GIT_BRANCH=master"                             <-- branch to build
#     -v /path/to/gatb-core-source:/tmp/gatb-core-code \ <-- source code
#     -v /path/to/gatb-core-build:/tmp/gatb-core-build \ <-- compiled code
#     gatb_core_machine \                                <-- container to start
#     gatb-compile.sh                                    <-- script to run
#
#   First of all, we have retain that the code is not compiled within the
#   container. Instead we use two external volumes bound to the container using
#   two docker run "-v" arguments. These two volumes simply target:
#
#      1. a directory containing the GATB-Core source code, i.e. a "git clone" of
#         GATB-Core repository;
#      2. a directory containing the compiled code.
#
#   Using such a design, you can work with an existing clone of GATB-Core 
#   repository and you can easily access the compiled code.
#
#   GATB-Core source code directory (hereafter denoted as "gatb-core-source") must
#   exist on the host system, but it can be empty. In such a case, the container
#   will do the git clone. Thus, gatb-core-source is passed to docker run as 
#   follows:
#
#      -v /full/path/to/your/gatb-core-source:/tmp/gatb-core-code
#
#      (do not modify "/tmp/gatb-core-code": this is the mount path within the 
#       container)
#
#   GATB-Core compiled code directory (hereafter denoted as "gatb-core-build")
#   must also exist on the host system. In all case, the container will erase its
#   content before running the code compiling procedure.  Thus, gatb-core-build 
#   is passed to docker run as follows:
#
#      -v /full/path/to/your/gatb-core-build:/tmp/gatb-core-build
#
#      (do not modify "/tmp/gatb-core-build": this is the mount path within the 
#       container)
#
#   Finally, the docker run also accepts an optional environment variable: the 
#   GATB-Core branch to compile. Simply pass that information using the "-e"
#   argument of docker run as follows:
#
#      -e "GIT_BRANCH=master"
#
#      replace "master" by an appropriate value, i.e. a git branch or tag.
#
#   If "-e" is not provided to docker run, then the master branch of GATB-Core 
#   is compiled.
#
#   All in all, the GATB-Core compiler machine can be started as follows:
#
#   docker run --name gatb_core_machine \
#              -i -t \                       <-- remove if running from Jenkins/slave
#                                                (TTY not allowed)
#              -e "GIT_BRANCH=master"
#              -v /path/to/gatb-core-source:/tmp/gatb-core-code \
#              -v /path/to/gatb-core-build:/tmp/gatb-core-build \
#              gatb_core_machine \
#              gatb-compile.sh
#
#   Sample command from the real life: docker run --name py_gatb_machine -i -t -e "GIT_BRANCH=master" -v /Users/pdurand/tmp/gatb-core/docker:/tmp/gatb-core-code -v /Users/pdurand/tmp/gatb-core/docker:/tmp/gatb-core-build gatb_core_machine gatb-compile.sh
#    docker run --name py_gatb_machine -i -t -e "GIT_BRANCH=master" -v /Volumes/DATA_1/inria/tmp/docker:/tmp/py-gatb-code -v /Volumes/DATA_1/inria/tmp/docker:/tmp/py-gatb-build py_gatb_machine py-gatb-compile.sh
# ### Test compile code.
#
#   In the above docker run command, you can replace 
#
#     gatb-compile.sh 
#
#   by 
#
#     gatb-test.sh 
#
#   to run unit tests of the freshly compiled GATB-Core library.
#                            
# ### Additional notes
# 
#   Root access inside the container:
#
#     - if running: docker exec -it py_gatb_machine bash
#
#     - if not yet running: docker run --rm -i -t py_gatb_machine bash
#
#######################################################################################

# ###
#     Base commands
#
#     We use a Debian 8 (Jessie) Linux
#
FROM debian:jessie

# who to blame?
MAINTAINER Patrick Durand patrick.durand@inria.fr

# ###
#    Configuring gcc and cmake release
#
ENV GCC_VERSION=4.9 \
    CMAKE_SERIES=3.7 \
    CMAKE_VERSION=3.7.2
    
# ###
#     Package installation and configuration
#
#     install latest packages of the base system
#     as well as packages required to compile GATB-Core
#
RUN apt-get update && apt-get -y dist-upgrade \
    && apt-get install -y --no-install-recommends vim git wget make zlib1g-dev libcppunit-dev \
    && apt-get clean \
    && git config --global http.sslVerify false

# ###
#     Compiler installation
#
#     We need a c/c++ compiler in an appropriate release.
#     Note: update-alternatives used by cmake installer (./boostrap)
#           to locate gcc
#
RUN apt-get install -y --no-install-recommends \
    gcc-${GCC_VERSION} g++-${GCC_VERSION} gcc-${GCC_VERSION}-base \
    && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-${GCC_VERSION} 100 \
    && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-${GCC_VERSION} 100 \
    && apt-get clean 

# ###
#     CMAKE installation
#
#     we need cmake in aparticular release; we do not use: apt-get 
#     install cmake since we have to control which version we use.
#     Cmake install procedure: https://cmake.org/install/
#
RUN cd /opt \
    && export CMAKE_URL="http://cmake.org/files/v${CMAKE_SERIES}/cmake-${CMAKE_VERSION}.tar.gz" \
    && wget --no-check-certificate ${CMAKE_URL} -O - | tar xzf - \
    && cd cmake-${CMAKE_VERSION} \
    && ./bootstrap && make && make install && cd /opt && rm -rf cmake-${CMAKE_VERSION} 
    
RUN apt-get install -y --no-install-recommends python3 python3-dev python3-pip \
    && apt-get clean \
    && pip3 install Cython --install-option="--no-cython-compile"

# ###
#     GATB-Core management scripts
#
#COPY py-gatb-compile.sh /usr/local/bin/

RUN cd /tmp \
    && git clone --recursive https://github.com/Piezoid/pyGATB.git 

#COPY CMakeLists.py /tmp/pyGATB/CMakeLists.txt

#RUN cd /tmp \
#    && mkdir build && cd build \
#    && cmake -D CMAKE_BUILD_TYPE=Release ../pyGATB \
#    && make \
#    && python3 setup.py install \
#    && cd /tmp && rm -rf build && rm -rf pyGATB
