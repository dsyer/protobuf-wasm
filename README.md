## Compiling the WASM

You need WASM-compiled libraries for `protobuf` and `protobuf-c`. Those require some work.

### Building Protobuf

Building `protobuf` for WASM (https://github.com/protocolbuffers/protobuf) using emscripten wasn't too complicated. First let's set up a build area:

```
$ mkdir tmp
$ cd tmp
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