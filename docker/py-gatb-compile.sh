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
  if [ ! -d ${PYGATB_SOURCE} ]; then
    git clone --single-branch --depth 1 -b ${GIT_BRANCH} ${PYGATB_GITURL} ${PYGATB_SOURCE}
    cd ${PYGATB_SOURCE} && git submodule init && git submodule update --depth 1
  else
    cd ${PYGATB_SOURCE}
    git checkout ${GIT_BRANCH}
  fi
fi

# Prepare a fresh build directory
if [ -d ${PYGATB_BUILD} ]; then
    rm -rf ${PYGATB_BUILD}
fi
mkdir -p ${PYGATB_BUILD}
cd ${PYGATB_BUILD}

# Compile source code
cmake -D CMAKE_BUILD_TYPE=Release ${PYGATB_SOURCE} $@
make ${PARALLEL_OPT}

# Test, distribute and install
python3 setup.py test
python3 setup.py bdist
python3 setup.py install
