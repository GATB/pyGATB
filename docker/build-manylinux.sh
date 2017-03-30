#!/bin/bash
#***************************************************************************
# Compiles pyGATB wheels inside a docker container.
# The container is made from an old linux distribution (CentOS 5) for maxiumum
# binary compatibility.
#
# The parent directory to the repository is mounted inside the container. The
# following subdirectories are acceded :
#  - pyGATB: repository, not modified,
#  - pyGATB-build-manylinux: contains the build, created, emptied if "keep-build",
#    file is not present,
#  - artifacts: contains the generated wheels, created.
#
#
# Author: Maël Kerbiriou
# Created: March 2017
#****************************************************************************
set -e
cd $(dirname $0)/context

docker build --pull -t pygatb/manylinux1_compiler -f Dockerfiles/Dockerfile.manylinux_compiler .

# Run compilation (kill switch: "docker container stop manylinux1-compilation")
docker run --rm -v "$(realpath "../../.."):/mnt/" --name "manylinux1-compilation" pygatb/manylinux1_compiler


