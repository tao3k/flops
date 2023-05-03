{
  inputs = {
    nixlib.url = "github:nix-community/nixpkgs.lib";
    POP.url = "github:divnix/POP";
    yants.url = "github:divnix/yants";

    haumea.url = "github:nix-community/haumea";
    haumea.inputs.nixpkgs.follows = "nixlib";

    namaka.url = "github:nix-community/namaka/v0.1.1";
    namaka.inputs.haumea.follows = "haumea";

    dmerge.url = "github:divnix/dmerge";
    dmerge.inputs.haumea.follows = "haumea";
    dmerge.inputs.namaka.follows = "namaka";
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = {
    self,
    nixlib,
    POP,
    nixpkgs,
    ...
  } @ inputs: let
    lib = import ./src/__loader.nix self.inputs;
    inherit (lib.flake) pops;
  in {
    inherit lib;
    checks = inputs.namaka.lib.load {
      src = ./tests;
      inputs = {
        lib = lib // inputs.nixlib.lib;
        inputs =
          inputs
          // {
            self.sourceInfo = {
              outPath = "constant-self";
              rev = "constant-rev";
            };
          };
      };
    };
  };
}
