#!/bin/bash
#******************************************************************************
# Installs CMake from sources.
# This is intended to be ran during the build time of containers.
#
#
# Author: Maël Kerbiriou, Patrick Durand, Inria
# Created: March 2017
#******************************************************************************
set -eo pipefail

CMAKE_VERSION="${1:-3.7.2}"
TMP_DIR="${TMP_DIR:-/tmp}"

CMAKE_SERIES=$(echo "$CMAKE_VERSION" | sed -r 's/^([0-9]+)\.([0-9]+).*$/\1.\2/')
CMAKE_URL="http://cmake.org/files/v${CMAKE_SERIES}/cmake-${CMAKE_VERSION}.tar.gz"
CMAKE_DIR="$TMP_DIR/cmake-${CMAKE_VERSION}"

# Download CMake's sources
cd "$TMP_DIR"
wget --no-check-certificate ${CMAKE_URL} -O - | tar xzf -

# Build and install
cd "$CMAKE_DIR"
./bootstrap
make ${PARALLEL_OPT}
make install

# Cleanup
rm -rf "$CMAKE_DIR"
