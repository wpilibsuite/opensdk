# Copyright 2021-2023 Ryan Hirasaki
# 
# This file is part of OpenSDK
#
# OpenSDK is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# OpenSDK is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with OpenSDK; see the file COPYING. If not see
# <http://www.gnu.org/licenses/>.

mk_file_dir := $(abspath $(shell dirname $(MAKE)))

WPI_TARGET ?= roborio
WPI_TARGET_PORT ?= cortexa9_vfpv3
WPI_HOST ?= $(shell sh $(mk_file_dir)/utils/extra/guess-host.sh)
USE_DOCKER ?= $(shell sh $(mk_file_dir)/utils/extra/guess-docker.sh)


ifeq ($(USE_DOCKER), true)
	runner := $(mk_file_dir)/docker.sh
	workdir := /work
else
	runner :=
	workdir := $(PWD)
endif

.PHONY: any frontend backend test clean

any:
	@echo "Please manually select a command such as frontend, backend, sign, test, or clean."
	@/bin/false

# Do note that the current implementations of frontend and backend could have
# name collisions if the tuple is the same. (roborio sumo vs. roborio-hardknott)

frontend:
	$(runner) bash ./utils/build-frontend.sh \
		${workdir}/hosts/${WPI_HOST}.env \
		${workdir}/targets/${WPI_TARGET} \
		${WPI_TARGET_PORT}

backend:
	$(runner) bash ./utils/build-backend.sh \
		${workdir}/hosts/${WPI_HOST}.env \
		${workdir}/targets/${WPI_TARGET} \
		${WPI_TARGET_PORT}

sign:
	$(runner) bash ./utils/sign-toolchain.sh \
		${workdir}/hosts/${WPI_HOST}.env \
		${workdir}/targets/${WPI_TARGET} \
		${WPI_TARGET_PORT}

test:
	$(runner) bash ./utils/test-toolchain.sh \
		${workdir}/hosts/${WPI_HOST}.env \
		${workdir}/targets/${WPI_TARGET} \
		${WPI_TARGET_PORT}

clean:
	$(runner) rm -rf build downloads || true
