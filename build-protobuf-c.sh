#!/bin/bash

cd build/protobuf-c

if ! [ -e Makefile ]; then
	./autogen.sh
	EMMAKEN_CFLAGS=-I../protobuf/src EM_PKG_CONFIG_PATH=../protobuf emconfigure ./configure --host=none-none-none
fi

if ! [ -e Makefile ]; then
	echo "Makefile no created"
	exit 1
fi

EMMAKEN_CFLAGS='-I../protobuf/src -L../protobuf/src/.libs' emmake make

if ! [ -e protobuf-c/.libs/libprotobuf-c.a ]; then
	echo "No library. Building native protoc-gen-c."
	if ! [ -e ../protobuf-c-native/protoc-c/protoc-gen-c ]; then
		git worktree add ../protobuf-c-native 2> /dev/null
		(cd ../protobuf-c-native; ./autogen.sh && ./configure && make)
	fi
	cp ../protobuf-c-native/protoc-c/protoc-gen-c ./protoc-c/
	chmod +x ./protoc-c/protoc-gen-c
	cp ../protobuf-c-native/t/generated-code2/cxx-generate-packed-data t/generated-code2
	chmod +x t/generated-code2/cxx-generate-packed-data
	EMMAKEN_CFLAGS='-I../protobuf/src -L../protobuf/src/.libs' emmake make
fi