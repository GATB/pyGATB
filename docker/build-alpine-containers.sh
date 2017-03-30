#!/bin/bash
#***************************************************************************
# Generate low profile docker containers with pyGATB and jupyter notebook.
# Based on Alpine Linux.
#
# The parent directory to the repository is mounted inside the container. The
# following subdirectories are acceded :
#  - pyGATB: repository, not modified,
#  - pyGATB-build-debian: contains the build, created, emptied if "keep-build",
#    file is not present,
#  - artifacts: contains the generated images, created.
#
# Author: Maël Kerbiriou
# Created: March 2017
#****************************************************************************
set -eo pipefail
cd "$(dirname $0)/context"

WORK_DIR=${WORK_DIR:-$(realpath "../../..")}
ARTIFACTS_DIR="$WORK_DIR/artifacts"

# Base container
docker build -t pygatb/alpine_runtime_base -f Dockerfiles/Dockerfile.alpine_runtime_base .

# Compiler environment
docker build -f Dockerfiles/Dockerfile.alpine_compiler -t pygatb/alpine_compiler .

# Run compilation (kill switch: "docker container stop pygatb-alpine-compilation")
docker run --rm --name "pygatb-alpine-compilation" \
    -v "${WORK_DIR}:/mnt" \
    -e "PYGATB_BUILD=/mnt/pyGATB-build-alpine" \
    pygatb/alpine_compiler

# Place the egg in context for subsequent docker builds
PYGATB_EGG=($ARTIFACTS_DIR/pyGATB*.egg)
mv "$PYGATB_EGG" .
PYGATB_EGG=$(basename "$PYGATB_EGG")

# Copy samples in context dir
cp -r "$WORK_DIR/pyGATB/samples" .

# Runtime container
docker build -f Dockerfiles/Dockerfile.alpine_runtime -t pygatb/alpine_runtime --build-arg "PYGATB_EGG=$PYGATB_EGG" .

rm "$PYGATB_EGG"
rm -rf samples

# Jupyter notebook container
docker build -f Dockerfiles/Dockerfile.alpine_notebook -t pygatb/alpine_notebook .

OUT_ARCHIVE="$ARTIFACTS_DIR/pyGATB_alpine_images.tar.xz"
rm -f "$OUT_ARCHIVE"
docker save pygatb/alpine_notebook pygatb/alpine_runtime | xz > $OUT_ARCHIVE
