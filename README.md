## Concourse bootstrap build for arm

See [concourse/concourse#1379](https://github.com/concourse/concourse/issues/1379) for more information

### Building

Make sure you have a working Docker installation on a linux x86\_64
machine or Mac. The build process has been tested on MacOS Mojave with Docker 18.09.2.

To make an arm build run:

```sh
./create.sh linux arm
```

To make an aarch64 build run:

```sh
./create.sh linux aarch64
```

By default verbose mode is used

### output

A docker image is created called concourse-arm that runs concourse.

### Missing features

Resource types are currently not included
