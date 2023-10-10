{
  inputs = {
    nixlib.url = "github:nix-community/nixpkgs.lib";
    POP.url = "github:divnix/POP";
    POP.inputs.nixpkgs.follows = "";
    POP.inputs.flake-compat.follows = "";
    yants.url = "github:divnix/yants";

    haumea.url = "github:nix-community/haumea";
    haumea.inputs.nixpkgs.follows = "nixlib";

    dmerge.url = "github:divnix/dmerge";
    dmerge.inputs.haumea.follows = "haumea";
    dmerge.inputs.nixlib.follows = "nixlib";
    dmerge.inputs.yants.follows = "yants";

    call-flake.url = "github:divnix/call-flake";
  };
  outputs =
    { self, ... }@inputs:
    let
      lib = import ./src/__loader.nix self.inputs;
    in
    {
      inherit lib;
      examples = import ./examples/_loader.nix {
        inherit inputs;
        lib = lib // inputs.nixlib.lib;
      };
    };
}
