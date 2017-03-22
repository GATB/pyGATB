#!/bin/bash
#***************************************************************************
# GATB-Core management script: compile source code using a Docker container.
#
# When running inside its Docker container, we expect to find
# two working paths (inside the container):
#  /tmp/gatb-core-code: will contain the git clone of GATB-Core
#  /tmp/gatb-core-build: will contain the compiled code 
#
# The script also uses the environment variable: GIT_BRANCH, than can
# be set to an appropriate GATB-Core branch. If not set, we work on
# the master branch.
#
#
# Author: Patrick Durand, Inria
# Created: February 2017
#****************************************************************************
set -eo pipefail
#set -xv

PYGATB_SOURCE=/tmp/py-gatb-code
PYGATB_BUILD=/tmp/py-gatb-build
PYGATB_GITURL="https://github.com/Piezoid/pyGATB.git"

if [ -z ${GIT_PROVIDER} ]; then
  GIT_PROVIDER="hub"
fi

# git management not done for Jenkins/CI (Inria only)
if [ ! ${GIT_PROVIDER} == "ci" ]; then

#   set default branch to master if not specified otherwise using
#   GIT_BRANCH environment variable
  if [ -z ${GIT_BRANCH} ]; then
   GIT_BRANCH=master
  fi

  # Figure out whether or not we have to get GATB-Core source code
  cd ${PYGATB_SOURCE}
  if [ ! -d "pyGATB" ]; then
    git clone --single-branch --depth 1 -b ${GIT_BRANCH} ${PYGATB_GITURL}
    cd pyGATB && git submodule init && git submodule update --depth 1
  else
    cd pyGATB
    git checkout ${GIT_BRANCH}
  fi
fi

# Prepare a fresh build directory
cd ${PYGATB_BUILD}
if [ -d "build" ]; then
    rm -rf build
fi

mkdir -p build
cd build

# Compile source code
cmake -D CMAKE_BUILD_TYPE=Release ${PYGATB_SOURCE}/pyGATB $@
make ${PARALLEL_OPT}

# Test, distribute and install
python3 setup.py test
python3 setup.py bdist_egg
python3 setup.py install

