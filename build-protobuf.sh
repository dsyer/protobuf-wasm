#!/bin/bash

branch=v3.12.4

cd build/protobuf
if ! git branch | grep -q ${branch}; then
	git checkout ${branch}
fi
if ! [ -e Makefile ]; then
	./autogen.sh
	emconfigure ./configure --host=none-none-none
fi
emmake make