#!/bin/bash
#***************************************************************************
# pyGATB compilation script: build wheels inside a pypa/manylinux1 Docker container.
#
# When running inside its Docker container, we expect to find
# the following working paths (inside the container):
#  - /tmp/pyGATB: repository, not modified,
#  - /tmp/pyGATB-build-manylinux: contains the build, created, emptied if "keep-build",
#    file is not present,
#  - /tmp/artifacts: contains the generated wheels, created.
#
#
# Author: Maël Kerbiriou ; Patrick Durand, Inria
# Created: March 2017
#****************************************************************************
set -eo pipefail
#set -xv # For debugging

# Where to find the pyGATB repository
PYGATB_SOURCE="${PYGATB_SOURCE:-/mnt/pyGATB}"
# Build directory
PYGATB_BUILD="${PYGATB_BUILD:-/mnt/pyGATB-build-manylinux}"
# Where to put the wheels
ARTIFACTS_DIR="${ARTIFACTS_DIR:-/mnt/artifacts}"
PARALLEL_OPT="${PARALLEL_OPT:--j4}"

PYGATB_VERSION=$(cat "$PYGATB_SOURCE/src/VERSION")

# Prepare a fresh build directory
mkdir -p "$PYGATB_BUILD"
cd "$PYGATB_BUILD"
if [[ ! -f keep-build ]]; then
    find . -mindepth 1 -delete
fi

# Loop over Python3 versions
for PY_MINOR in $(ls /opt/python/ | sed -rn 's/cp3([0-9]+)-cp3\1m$/\1/p');
do
    # Selected python environnement
    PY_BIN_DIR=/opt/python/cp3${PY_MINOR}-cp3${PY_MINOR}m/bin/
    PY_INCLUDE_DIR=/opt/python/cp3${PY_MINOR}-cp3${PY_MINOR}m/include/python3.${PY_MINOR}m/
    # Paths to artifacts
    WHL_PREFIX="${ARTIFACTS_DIR}/pyGATB-${PYGATB_VERSION}-cp3${PY_MINOR}-cp3${PY_MINOR}m"
    LINUX_WHL="${WHL_PREFIX}-linux_x86_64.whl"
    MANYLINUX_WHL="${WHL_PREFIX}-manylinux1_x86_64.whl"

    # Configure and build with the selected python includes
    cmake . "$PYGATB_SOURCE" -DCMAKE_BUILD_TYPE=Release -DENABLE_LTO=ON \
        -DPYTHON_EXECUTABLE="${PY_BIN_DIR}/python" \
        -DPYTHON_INCLUDE_DIR="$PY_INCLUDE_DIR" \
        "$@"

    make $PARALLEL_OPT

    "${PY_BIN_DIR}/pip" wheel . -w "$ARTIFACTS_DIR"

    # "Repair" the wheel (adds shared libraries, and retag the wheel for manylinux1)
    auditwheel repair "$LINUX_WHL" -w "$ARTIFACTS_DIR"
    if [[ -f "$MANYLINUX_WHL" ]]; then
        rm "$LINUX_WHL"
    else
        echo "$MANYLINUX_WHL was not produced !"
        exit 1
    fi
done
