HOST := linux_x86_64
TARGET := roborio-sumo
TARGET_PORT := cortexa9_vfpv3
DOCKER := false

mk_file_dir := $(abspath $(shell dirname $(MAKE)))

ifeq ($(DOCKER), true)
	runner := $(mk_file_dir)/docker.sh
else
	runner :=
endif

.PHONY: any frontend backend test clean

any:
	@echo "Please manually select a command such as frontend, backend, test, or clean."
	@/bin/false

# Do note that the current implementations of frontend and backend could have
# name collisions if the tuple is the same. (roborio sumo vs. roborio-hardknott)

frontend:
	$(runner) bash ./utils/build-frontend.sh \
		${PWD}/hosts/${HOST}.env \
		${PWD}/targets/${TARGET} \
		${TARGET_PORT}

backend:
	$(runner) bash ./utils/build-backend.sh \
		${PWD}/hosts/${HOST}.env \
		${PWD}/targets/${TARGET} \
		${TARGET_PORT}

test:
	$(runner) bash ./utils/test-toolchain.sh \
		${PWD}/hosts/${HOST}.env \
		${PWD}/targets/${TARGET} \
		${TARGET_PORT}

clean:
	$(runner) rm -r build downloads


