HOST := linux_x86_64
TARGET := roborio-sumo
TARGET_PORT := cortexa9_vfpv3

.PHONY: any frontend backend test clean

any:
	@echo "Please manually select a command such as frontend, backend, test, or clean."
	@/bin/false

# Do note that the current implementations of frontend and backend could have
# name collisions if the tuple is the same. (roborio sumo vs. roborio-hardknott)

frontend:
	bash ./utils/build-frontend.sh \
		${PWD}/hosts/${HOST}.env \
		${PWD}/targets/${TARGET} \
		${TARGET_PORT}

backend:
	bash ./utils/build-backend.sh \
		${PWD}/hosts/${HOST}.env \
		${PWD}/targets/${TARGET} \
		${TARGET_PORT}

test:
	bash ./utils/test-toolchain.sh \
		${PWD}/hosts/${HOST}.env \
		${PWD}/targets/${TARGET} \
		${TARGET_PORT}

clean:
	rm -r build downloads


