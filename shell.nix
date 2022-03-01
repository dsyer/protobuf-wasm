with import <nixpkgs> { };
mkShell {

  name = "env";
  buildInputs = [
    figlet wasmtime wabt emscripten nodejs cmake check protobuf protobufc pkg-config
  ];

  postShellHook = ''
    figlet ":wasm:"
  '';

}