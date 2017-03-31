#!/bin/bash
#***************************************************************************
# Compiles pyGATB egg inside a debian jessie containter using these dependencies:
#
#     -->  gcc 4.9
#     -->  CMake 3.7.2
#     -->  Python 3.4
#     -->  Cython 0.25
#
# The parent directory to the repository is mounted inside the container. The
# following subdirectories are acceded :
#  - pyGATB: repository, not modified,
#  - pyGATB-build-debian: contains the build, created, emptied if "keep-build",
#    file is not present,
#  - artifacts: contains the generated egg, created.
#
#
# Author: Maël Kerbiriou
# Created: March 2017
#****************************************************************************
set -e

SCRIPT_DIR=$( cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P )
cd ${SCRIPT_DIR}/context

docker build -t "pygatb/debian_compiler" -f Dockerfiles/Dockerfile.debian_compiler .

# Run compilation (kill switch: "docker container stop manylinux1-compilation")
docker run --rm --name "debian-compilation" \
    -v "${SCRIPT_DIR}/../..:/mnt/" \
    -e "PYGATB_BUILD=/mnt/pyGATB-build-debian" \
    pygatb/debian_compiler
