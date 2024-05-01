{ inputs, cell }:
let
  inherit (inputs) nixpkgs omnibus;
  inputs' = (inputs.omnibus.pops.flake.setSystem nixpkgs.system).inputs;
in
{
  configs = inputs.omnibus.pops.configs {
    inputs = {
      inputs = {
        inherit (inputs') nixfmt git-hooks;
        inherit (inputs) std;
        inherit nixpkgs;
      };
    };
  };
}
