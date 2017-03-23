#!/bin/sh
set -eo pipefail

# Where to ouput the .tar.xz containing the distributed docker images
[ -z "$IMAGES_ARCHIVE_DIR" ] && IMAGES_ARCHIVE_DIR=$(pwd)

cd $(dirname $0)

# Where to find the pyGATB repo (directory on the host containing the repo dir)
[ -z "$PYGATB_SOURCE" ] && PYGATB_SOURCE=$(realpath "../..")
# Where to find the build dir (directory on the host containing the build dir)
[ -z "$PYGATB_BUILD" ] && PYGATB_BUILD="$PYGATB_SOURCE"
# Build dir name
[ -z "$PYGATB_BUILD_DIRNAME" ] && PYGATB_BUILD_DIRNAME="pyGATB-alpine-build"
# By default, use the source tree as is (don't pull or checkout anything)
[ -z "$GIT_PROVIDER" ] && GIT_PROVIDER="ci"
[ -z "$PARALLEL_OPT" ] && PARALLEL_OPT="-j4"

# Base container
docker build -f Dockerfile.alpine_runtime_base -t pygatb/alpine_runtime_base .

# Compiler environment
docker build -f Dockerfile.alpine_compiler -t pygatb/alpine_compiler .

# Run compilation (kill switch: "docker container stop pygatb-alpine-compilation")
docker run --rm --name "pygatb-alpine-compilation" \
    -v "$PYGATB_SOURCE:/tmp/py-gatb-code" \
    -v "$PYGATB_BUILD:/tmp/py-gatb-build" \
    -e "GIT_PROVIDER=$GIT_PROVIDER" \
    -e "PYGATB_BUILD_DIRNAME=$PYGATB_BUILD_DIRNAME" \
    -e "PARALLEL_OPT=$PARALLEL_OPT" \
    pygatb/alpine_compiler py-gatb-compile.sh -DENABLE_LTO=ON

# Extract the egg for subsequent docker builds
PYGATB_EGG=($PYGATB_BUILD/$PYGATB_BUILD_DIRNAME/dist/pyGATB*.egg)
cp "$PYGATB_EGG" .
PYGATB_EGG=$(basename "$PYGATB_EGG")

# Copy samples in work dir
cp -r "$PYGATB_SOURCE/pyGATB/samples" .

# Runtime container
docker build -f Dockerfile.alpine_runtime -t pygatb/alpine_runtime --build-arg "PYGATB_EGG=$PYGATB_EGG" .

rm "$PYGATB_EGG"
rm -rf samples

# Jupyter notebook container +
docker build -f Dockerfile.alpine_notebook -t pygatb/alpine_notebook .

OUT_ARCHIVE="$IMAGES_ARCHIVE_DIR/docker_images.tar.xz"
rm -f "$OUT_ARCHIVE"
docker save pygatb/alpine_notebook pygatb/alpine_runtime | xz > $OUT_ARCHIVE
