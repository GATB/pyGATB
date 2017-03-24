#######################################################################################
#
# Dockerfile to start a pyGATB/Ptyhon compiling machine using these dependencies:
#
#     -->  gcc 4.9 
#     -->  CMake 3.7.2
#     -->  Python 3.4
#     -->  Cython 0.25
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
#   Running the container means that you want to compile pyGATB. For that
#   purpose, docker run expects some information, as illustrated in this
#   command:
#
#   docker run
#     -i -t
#     -e "GIT_BRANCH=master"                                       <--
#     -v /path/to/py-gatb-source:/tmp/py-gatb-code                 <-- source code
#     -v /path/to/py-gatb-build:/tmp/py-gatb-build                 <-- compiled code (optional)
#     py_gatb_machine                                              <-- container to start
#     /tmp/py-gatb-code/pyGATB/docker/py-gatb-compile.sh           <-- script to run
#       -DCMAKE_CXX_FLAGS_RELEASE="-march=native -Ofast -DNDEBUG"  <-- cmake arguments
#
#   First of all, we have retain that the code is not compiled within the
#   container. Instead we use two external volumes bound to the container using
#   two docker run "-v" arguments. These two volumes simply target:
#
#      1. a directory containing the pyGATB source code, i.e. a "git clone" of
#         pyGATB repository;
#      2. a directory containing the compiled code.
#
#   Using such a design, you can work with an existing clone of pyGATB
#   repository and you can easily access the compiled code.
#
#   pyGATB source code directory (hereafter denoted as "py-gatb-source") must
#   exist on the host system, but it can be empty. In such a case, the container
#   will do the git clone. Thus, py-gatb-source is passed to docker run as
#   follows:
#
#      -v /full/path/to/your/py-gatb-source:/tmp/py-gatb-code
#
#      (do not modify "/tmp/py-gatb-code": this is the mount path within the
#       container)
#
#   pyGATB compiled code directory (hereafter denoted as "py-gatb-build")
#   must also exist on the host system. In all case, the container will erase its
#   content before running the code compiling procedure.  Thus, py-gatb-build
#   is passed to docker run as follows:
#
#      -v /full/path/to/your/py-gatb-build:/tmp/py-gatb-build
#
#      (do not modify "/tmp/py-gatb-build": this is the mount path within the
#       container)
#
#   Finally, the docker run also accepts an optional environment variable: the 
#   pyGATB branch to compile. Simply pass that information using the "-e"
#   argument of docker run as follows:
#
#      -e "GIT_BRANCH=master"
#
#      replace "master" by an appropriate value, i.e. a git branch or tag.
#
#   If "-e" is not provided to docker run, then the master branch of pyGATB
#   is compiled.
#
#   All in all, the pyGATB compiler machine can be started as follows:
#
#   docker run --name py_gatb_machine \
#              -i -t \                       <-- remove if running from Jenkins/slave
#                                                (TTY not allowed)
#              -e "GIT_BRANCH=master"
#              -v /path/to/py-gatb-source:/tmp/py-gatb-code \
#              -v /path/to/py-gatb-build:/tmp/py-gatb-build \
#              py_gatb_machine
#
#
#   Sample command from the real life: docker run --name py_gatb_machine -i -t -e "GIT_BRANCH=master" -v /Users/pdurand/tmp/py-gatb/docker:/tmp/py-gatb-code -v /Users/pdurand/tmp/py-gatb/docker:/tmp/py-gatb-build py_gatb_machine
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
LABEL mainteners="Patrick Durand <patrick.durand@inria.fr>; Maël Kerbiriou <mael.kerbiriou@free.fr>"

# ###
#    Configuring gcc and cmake release
#
ENV GCC_VERSION=4.9 \
    CMAKE_SERIES=3.7 \
    CMAKE_VERSION=3.7.2
# How many (make) jobs to run in parallel ?
ENV PARALLEL_OPT="-j4"

# ###
#     Package installation and configuration
#
#     install latest packages of the base system
#     as well as packages required to compile pyGATB
#
RUN echo "APT::Install-Recommends \"false\";\nAPT::Install-Suggests \"false\";" >> /etc/apt/apt.conf \
    && apt-get update && apt-get -y dist-upgrade \
    && apt-get install -y vim git wget make zlib1g-dev \
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
    && ./bootstrap && make ${PARALLEL_OPT} && make install && cd /opt && rm -rf cmake-${CMAKE_VERSION}

# ###
#     Python3 installation
#
#     Python, pip and Cython
#
RUN apt-get install -y python3 python3-dev python3-pip \
    && apt-get clean \
    && pip3 install pytest-runner pytest Cython --install-option="--no-cython-compile"

# ###
#     Build scripts
#
CMD ["/tmp/py-gatb-code/pyGATB/docker/py-gatb-compile.sh"]
#COPY py-gatb-compile.sh /usr/local/bin/
#RUN py-gatb-compile.sh
