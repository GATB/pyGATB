#!/bin/bash
set -eo pipefail


cd $(dirname $0)

# Where to find the pyGATB repo (directory on the host containing the repo dir)
[ -z "$PYGATB_SOURCE" ] && PYGATB_SOURCE=$(realpath "..")
[ -z "$PARALLEL_OPT" ] && PARALLEL_OPT="-j4"



# Run compilation (kill switch: "docker container stop pygatb-alpine-compilation")
docker run --rm --name "pygatb-alpine-compilation" \
    -v "$PYGATB_SOURCE:/tmp/pyGATB" \
    -e "PARALLEL_OPT=$PARALLEL_OPT" \
    -it pygatb/manylinux1_x86_64 bash /tmp/pyGATB/docker/build-manylinux-inner.sh

exit 1

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
