{ lib, inputs }:
let
  inherit (lib) flake;
in
let
  callInputs =
    ((flake.pops.default.setInitInputs ./__nixpkgsFlake).setSystem "x86_64-linux")
    .outputs;
  nixpkgs = callInputs.nixpkgs;
in
nixpkgs.legacyPackages.appendOverlays [
  (import ./__nixpkgsFlake/overlays.nix inputs)
]
