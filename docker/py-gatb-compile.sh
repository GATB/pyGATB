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

# Where to find the pyGATB repo (directory containing the repo dir)
[ -z "$PYGATB_SOURCE" ] && PYGATB_SOURCE="/tmp/py-gatb-code"
# Where to find the build dir (directory containing the build dir)
[ -z "$PYGATB_BUILD" ] && PYGATB_BUILD="/tmp/py-gatb-build"
# Build dir name
[ -z "$PYGATB_BUILD_DIRNAME" ] && PYGATB_BUILD_DIRNAME="build"
[ -z "$PYGATB_GITURL" ] && PYGATB_GITURL="https://github.com/GATB/pyGATB.git"
[ -z "$PARALLEL_OPT" ] && PARALLEL_OPT="-j4"


# Source provider: "hub", or "ci" for skipping the git checkout process
[ -z $GIT_PROVIDER ] && GIT_PROVIDER=hub

# git management not done for Jenkins/CI (Inria only)
if [ ! $GIT_PROVIDER == "ci" ]; then
#   set default branch to master if not specified otherwise using
#   GIT_BRANCH environment variable
  if [ -z $GIT_BRANCH ]; then
   GIT_BRANCH=master
  fi

  # Figure out whether or not we have to get GATB-Core source code
  cd "${PYGATB_SOURCE}"
  if [ ! -d "pyGATB" ]; then
    git clone --single-branch --depth 1 -b ${GIT_BRANCH} ${PYGATB_GITURL}
    cd pyGATB && git submodule init && git submodule update --depth 1
  else
    cd pyGATB
    git checkout ${GIT_BRANCH}
  fi
fi

# Prepare a fresh build directory
cd "${PYGATB_BUILD}"
if [[ -d "$PYGATB_BUILD_DIRNAME" && ! -f "$PYGATB_BUILD_DIRNAME/keep-build" ]]; then
    rm -rf "$PYGATB_BUILD_DIRNAME"
fi

mkdir -p "$PYGATB_BUILD_DIRNAME"
cd "$PYGATB_BUILD_DIRNAME"

# Compile source code
cmake -D CMAKE_BUILD_TYPE=Release "${PYGATB_SOURCE}/pyGATB" $@
make ${PARALLEL_OPT}

# Test and distribute
python3 setup.py test
python3 setup.py bdist_egg

