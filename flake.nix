{
  inputs = {
    nixlib.url = "github:nix-community/nixpkgs.lib";
    POP.url = "github:divnix/POP";
    yants.url = "github:divnix/yants";

    haumea.url = "github:nix-community/haumea";
    haumea.inputs.nixpkgs.follows = "nixlib";

    namaka.url = "github:nix-community/namaka";
    namaka.inputs.haumea.follows = "haumea";
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
    lib = import ./src self.inputs;
    inherit (lib.flake) pops;
  in {
    inherit lib;
    checks = inputs.namaka.lib.load {
      flake = self;
      inputs = {
        inherit lib;
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
