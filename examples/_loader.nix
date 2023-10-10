{ lib, inputs }:
let
  inherit (inputs) nixlib;
  l = nixlib // builtins;
in
inputs.haumea.lib.load {
  src = ./.;
  inputs = {
    inherit inputs lib;
    inherit (lib) configs flake;
  };
}
