## WASM Libraries for Protobuf and Protobuf-c

If you need WASM-compiled libraries for `protobuf` and `protobuf-c` you can build them here:

```
$ make
$ ls -l *.tgz
-rw-r--r-- 1 vscode vscode 27920925 Mar  1 10:23 protobuf-wasm.tgz
$ tar -tzvf *.tgz
drwxr-xr-x vscode/vscode        0 2022-03-01 10:23 include/
drwxr-xr-x vscode/vscode        0 2022-03-01 10:28 include/protobuf-c/
-rwxr-xr-x vscode/vscode    33675 2022-03-01 10:23 include/protobuf-c/protobuf-c.h
drwxr-xr-x vscode/vscode        0 2022-03-01 10:23 lib/
-rw-r--r-- vscode/vscode   134310 2022-03-01 10:23 lib/libprotobuf-c.a
-rw-r--r-- vscode/vscode  5408500 2022-03-01 10:23 lib/libprotobuf-lite.a
-rw-r--r-- vscode/vscode 40387580 2022-03-01 10:23 lib/libprotobuf.a
-rw-r--r-- vscode/vscode 57765044 2022-03-01 10:23 lib/libprotoc.a
```

Some of the libraries are rather large, so the release tarball is likely to be 30MB or so.

## Usage

Those library archives have WASM blobs instead of object files and you can link them using a WASM compiler (e.g. `emscripten`). Example

```protobuf
syntax = "proto3";
message Person {
	string id = 1;
	string name = 2;
}
```

Then we can generate some C code:

```
$ protoc-c --c_out=. person.proto
```

which gives us `person.pb-c.c` and `person.pb-c.h`.

Then let's create a simple `person.c`:

```c
#include <stdio.h>
#include <stdlib.h>
#include "person.pb-c.h"

int main() {
	Person *person = malloc(sizeof(Person));
	person->id = "54321";
	person->name = "Juergen";
	printf("%s %s\n", person->id, person->name);
	return 0;
}
```

We can compile it with `gcc` and run it:

```
$ gcc person.pb-c.c person.c -lprotobuf-c  -o person
$ ./person
54321 Juergen
```

### Compiling a WASM

Unpack the library release:

```
$ tar -zxvf protobuf-wasm.tgz
```

> NOTE: The Ubuntu system `emscripten` fails to compile our `person.c` ("Error: Cannot find module 'acorn'"), but if you get the latest `emcc` from [`emsdk`](https://github.com/emscripten-core/emsdk) it works ().

Compile the WASM and run it:

```
$ emcc -Os -I ./include -s STANDALONE_WASM -s EXPORTED_FUNCTIONS="['_main']" ./lib/libprotobuf-c.a ./lib/libprotobuf.a person.c person.pb-c.c -o person.wasm
$ wasmtime person.wasm 
54321 Juergen
```

## Manual Build

### Building Protobuf

Building `protobuf` for WASM (https://github.com/protocolbuffers/protobuf) using emscripten wasn't too complicated. First let's set up a build area:

```
$ mkdir build
$ cd build
$ git clone https://github.com/protocolbuffers/protobuf
$ cd protobuf
```

Check the `PROTOBUF_VERSION` in the system:

```
$ grep PROTOBUF_VERSION /usr/include/google/protobuf/stubs/common.h 
#define GOOGLE_PROTOBUF_VERSION 3012004
```

That means `3.12.4` is installed, so we'll grab that and compile it:

```
$ git checkout v3.12.4
$ ./autogen.sh
$ emconfigure ./configure --host=none-none-none
$ emmake make
$ find . -name \*.a
./src/.libs/libprotobuf-lite.a
./src/.libs/libprotobuf.a
./src/.libs/libprotoc.a
```

There are loads of warnings about `LLVM version appears incorrect (seeing "12.0", expected "11.0")` but it seems to work.

### Building Protobuf-c

Checkout and prepare:

```
$ cd ..
$ git clone https://github.com/protobuf-c/protobuf-c
$ cd protobuf-c
```

Building `protobuf-c` is trickier because it has to point back to the `protobuf` build, and also has to be a compatible version (hence the `3.12.4` tag in `protobuf`):

```
$ ./autogen.sh
$ EMMAKEN_CFLAGS=-I../protobuf/src EM_PKG_CONFIG_PATH=../protobuf emconfigure ./configure --host=none-none-none
$ EMMAKEN_CFLAGS='-I../protobuf/src -L../protobuf/src/.libs' emmake make
```

The `make` command above most likely will fail a couple of times, while it tries to run tests. You can't ignore it, but you can work around it. The first time it fails because `protoc-gen-c` is not executable (it's a WASM), but you can copy the system executable with the same name into the same location (and set the executable bit) to move past that by running the same make command again. The second failure is another non-executable WASM used in tests in `t/generated-code2/cxx-generate-packed-data`. You can get a binary executable to swap with that by running `./autogen.sh && ./configure && make` in a fresh clone. Copy the generated executable on top of the WASM and set the executable bit, then make again:

```
$ EMMAKEN_CFLAGS='-I../protobuf/src -L../protobuf/src/.libs' emmake make
$ find . -name \*.a
./protobuf-c/.libs/libprotobuf-c.a
```