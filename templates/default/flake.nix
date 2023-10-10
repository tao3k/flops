{
  inputs = {
    haumea = {
      url = "github:nix-community/haumea/v0.2.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixlib.url = "github:nix-community/nixpkgs.lib";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flops.url = "github:gtrunsec/flops";
  };

  outputs =
    {
      self,
      haumea,
      nixlib,
      nixpkgs,
      flops,
    }:
    let
      l = nixlib.lib;
    in
    {
      eval = nixpkgs.lib.evalModules {
        modules = [ self.loadModules.outputs.default.programs.git ];
      };

      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ self.loadModules.outputs.default.programs.git ];
      };
      loadModules = flops.lib.haumea.pops.default.setInit {
        src = ./nixosModules;
        type = "nixosModules";
      };
    };
}
