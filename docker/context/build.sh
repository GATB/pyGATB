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
#set -xv # For debugging

# Where to find the pyGATB repository
PYGATB_SOURCE="${PYGATB_SOURCE:-/mnt/pyGATB}"
# Build directory
PYGATB_BUILD="${PYGATB_BUILD:-/mnt/pyGATB-build}"
# Where to put the artifacts
ARTIFACTS_DIR="${ARTIFACTS_DIR:-/mnt/artifacts}"
PARALLEL_OPT="${PARALLEL_OPT:--j4}"

# Prepare a fresh build directory
mkdir -p "$PYGATB_BUILD"
cd "$PYGATB_BUILD"
if [[ ! -f keep-build ]]; then
    find . -mindepth 1 -delete
fi

# Compile source code
cmake . -DCMAKE_BUILD_TYPE=Release "${PYGATB_SOURCE}" $@
make ${PARALLEL_OPT}

# Test and distribute
python3 setup.py test
python3 setup.py bdist_egg -d "$ARTIFACTS_DIR"

