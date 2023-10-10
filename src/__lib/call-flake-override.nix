{ lib }:
let
  lock = builtins.fromJSON (builtins.readFile ./__lock/flake.lock);
  flake-compat = builtins.fetchTarball {
    url = "https://github.com/gtrunsec/flake-compat/archive/${lock.nodes.flake-compat.locked.rev}.tar.gz";
    sha256 = lock.nodes.flake-compat.locked.narHash;
  };
in
src: override-inputs:
(import "${flake-compat}" { inherit src override-inputs; }).defaultNix.inputs
