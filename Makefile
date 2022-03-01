
srcs := build/protobuf build/protobuf-c

ALL: $(srcs)

build/protobuf: build
	cd build; git clone https://github.com/protocolbuffers/protobuf 2>/dev/null || echo "Not cloning $(@)"

build/protobuf-c: build
	cd build; git clone https://github.com/protobuf-c/protobuf-c 2>/dev/null || echo "Not cloning $(@)"

build:
	mkdir -p build