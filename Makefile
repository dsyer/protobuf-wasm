
srcs := build/protobuf build/protobuf-c

libsprotobuf := build/protobuf/src/.libs
libprotobuf := $(libsprotobuf)/libprotobuf.a
libsprotobufc := build/protobuf-c/protobuf-c/.libs
libprotobufc := $(libsprotobufc)/libprotobuf-c.a
libprotobufc.h := build/protobuf-c/protobuf-c/protobuf-c.h

release.tgz := protobuf-wasm.tgz

RELEASE: $(release.tgz)

ALL: $(libprotobuf) $(libprotobufc) $(libprotobufc.h)

$(release.tgz): ALL
	rm -rf build/release
	mkdir -p build/release/include/protobuf-c
	mkdir -p build/release/lib
	cp $(libsprotobuf)/*.a build/release/lib
	cp $(libsprotobufc)/*.a build/release/lib
	cp $(libprotobufc.h) build/release/include/protobuf-c
	(cd build/release && tar -czvf - *) > $(release.tgz)

$(libprotobuf): build/protobuf
	./build-protobuf.sh

$(libprotobufc): 
	./build-protobuf-c.sh

build/protobuf: build
	cd build; git clone https://github.com/protocolbuffers/protobuf 2>/dev/null || echo "Not cloning $(@)"

build/protobuf-c: build
	cd build; git clone https://github.com/protobuf-c/protobuf-c 2>/dev/null || echo "Not cloning $(@)"

build:
	mkdir -p build