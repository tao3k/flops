{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    std.url = "github:divnix/std";
  };
  outputs =
    { self, ... }@inputs:
    {
      inherit inputs;
      packages = inputs.nixpkgs.legacyPackages.x86_64-linux.hello;
    };
}
