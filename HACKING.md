# Building manually

Ideally you would want to download a prebuilt toolchain from CI/Gitbub releases.
But for those who want to modify the GNU toolchain you will need to build with
openSDK yourself.

NOTE: openSDK will utilize a linux container if `docker` is installed on the
build system. If you do not want this, set `USE_DOCKER` to `false`
(see below how to). Refer to the container image located
[here](https://github.com/wpilibsuite/docker-images/blob/main/opensdk-ubuntu/Dockerfile.20.04)
for packages needed on the host.

## Example to build a roboRIO toolchain for Windows hosts
```sh
make backend WPI_TARGET=roborio
make frontend WPI_TARGET=roborio WPI_HOST=windows_x86_64
```
