#!/bin/bash

set -ex

os=$1
arch=$2
docker build -f Dockerfile-builder -t concourse-builder scripts

rm -rf output
mkdir output
docker run --rm -it -v $(pwd)/output:/output -v $(pwd)/scripts/build.sh:/go/build.sh concourse-builder bash -c "./build.sh -o ${os} -a ${arch} -v"

docker build -f Dockerfile -t concourse-arm .
docker tag concourse-arm bchalk/concourse-arm:latest
docker push bchalk/concourse-arm:latest
