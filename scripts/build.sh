#!/bin/bash

set -e

VERSION="v5.3.0"

usage() { echo "Usage: $0 -a <arm|arm64|aarch64> -o <linux|darwin> [-v]" 1>&2; exit 1; }

while getopts ":a:o:v" opt; do
	case ${opt} in
		a)
			arch=${OPTARG}
			if  [ "$arch" == "arm" ]; then
				export GOARCH=arm
			elif [ "$arch" == "arm64" ]; then
				export GOARCH=arm64
			elif [ "$arch" == "aarch64" ]; then
				export GOARCH=arm64
			else
				usage
			fi
			;;
		o)
			os=${OPTARG}
			if [[ "$os" == "linux" ]]; then
				export GOOS=linux
			else
				usage
			fi
			;;
		v)
			set -x
			;;
		*) usage
		;;
	esac
done
[ -z "$arch" ] && usage

base="$PWD"
workdir="$base/workdir-$arch"

build_resource_type() {
	name=$1

	mkdir -p "$workdir/resources"

	[ -d "$name-resource" ] || git clone "https://github.com/concourse/$name-resource"

	pushd "$name-resource"
		git reset --hard
		git clean -ffxd

		for patch in "$base/patches/$arch/$name-resource/"*; do
			[[ -e $patch ]] || break
			git apply < "$patch"
		done

		cp "$base/qemu-$arch-static-3.0.0" .

		docker build -t "$name-resource" -f ./dockerfiles/alpine/Dockerfile .
		container_id=$(docker create "$name-resource")
		docker export "$container_id" | gzip > "$workdir/resources/$name-resource-deadbeef.tar.gz"
		docker rm "$container_id"
	popd
}

mkdir -p "$workdir"
pushd "$workdir"
	# get build scripts
	[ -d "ci" ] || git clone --recursive 'https://github.com/concourse/ci'
	# pushd ./ci
	# 	git reset --hard
	# 	for patch in "$base/patches/$arch/ci"*; do
	# 		[[ -e $patch ]] || break
	# 		git apply < "$patch"
	# 	done
	# popd

	# get concourse
	[ -d "concourse" ] || git clone --branch="$VERSION" --recursive 'https://github.com/concourse/concourse'

	# get final-version
	mkdir -p final-version
	echo -n "$VERSION" > final-version/version

	# build fly-rc
	mkdir -p linux-binary
	./fly-build
	rm -rf fly-rc
	mv linux-binary fly-rc


	# install gdn
	wget -O /usr/local/bin/gdn https://github.com/cloudfoundry/garden-runc-release/releases/download/v1.19.1/gdn-1.19.1
	chmod + /usr/local/bin/gdn
	
	./yarn-build
	# build resource types
	# build_resource_type "docker-image"
	# build_resource_type "git"
	# build_resource_type "s3"

	# mkdir -p concourse/blobs
	# rm -rf concourse/blobs/resources
	# mv resources concourse/blobs

	# build concourse

	mkdir -p binary
	./concourse-build linux arm

	rm -rf "output/linux-rc"
	mv concourse-linux "/output/linux-rc"
popd
