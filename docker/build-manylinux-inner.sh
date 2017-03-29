#!/bin/bash
set -eo pipefail

# Where to find the pyGATB repository
[ -z "$PYGATB_SOURCE" ] && PYGATB_SOURCE="/tmp/pyGATB"
# Build directory
[ -z "$PYGATB_BUILD" ] && PYGATB_BUILD="${PYGATB_SOURCE}/build-manylinux"
# Where to put the wheels
[ -z "$WHEELHOUSE" ] && WHEELHOUSE="${PYGATB_BUILD}/wheelhouse"
[ -z "$PARALLEL_OPT" ] && PARALLEL_OPT="-j4"

PYGATB_VERSION=$(cat "$PYGATB_SOURCE/src/VERSION")


# Prepare a fresh build directory
mkdir -p "$PYGATB_BUILD"
cd "$PYGATB_BUILD"
if [[ ! -f keep-build ]]; then
    find . -mindepth 1 -delete
fi


for PY_MINOR in 3 4 5 6
do
    PY_BIN_DIR=/opt/python/cp3${PY_MINOR}-cp3${PY_MINOR}m/bin/
    PY_INCLUDE_DIR=/opt/python/cp3${PY_MINOR}-cp3${PY_MINOR}m/include/python3.${PY_MINOR}m/
    cmake . "$PYGATB_SOURCE" -DCMAKE_BUILD_TYPE=Release -DENABLE_LTO=ON \
        -DPYTHON_EXECUTABLE="${PY_BIN_DIR}/python" \
        -DPYTHON_INCLUDE_DIR="$PY_INCLUDE_DIR"

    make $PARALLEL_OPT

    "${PY_BIN_DIR}/pip" wheel . -w "$WHEELHOUSE"

    auditwheel repair "${WHEELHOUSE}/pyGATB-${PYGATB_VERSION}-cp3${PY_MINOR}-cp3${PY_MINOR}m-linux_x86_64.whl"
    ls "${WHEELHOUSE}/pyGATB-${PYGATB_VERSION}-cp3${PY_MINOR}-cp3${PY_MINOR}m-manylinux1_x86_64.whl"
    rm "${WHEELHOUSE}/pyGATB-${PYGATB_VERSION}-cp3${PY_MINOR}-cp3${PY_MINOR}m-linux_x86_64.whl"
done


# PYGATB_BUILD="$PYGATB_SOURCE/build-
#
#  cmake . ../pyGATB -DCMAKE_BUILD_TYPE=Release -DENABLE_LTO=ON -DPYTHON_EXECUTABLE=/opt/python/cp3{PY_MINOR}-cp3{PY_MINOR}m/bin/python -DPYTHON_INCLUDE_DIR=/opt/python/cp3{PY_MINOR}-cp3{PY_MINOR}m/include/python3{PY_MINOR}m/ && make -j4 /opt/python/cp3{PY_MINOR}-3{PY_MINOR}m/bin/pip wheel .
