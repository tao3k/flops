{ inputs, lib }:
let
  inherit (inputs) POP dmerge;
  inherit (POP.lib) extendPop;
  inherit (lib.haumea) pops;

  A =
    with inputs.haumea.lib;
    pops.default.setInit {
      src = ../..;
      inputs = {
        inherit lib;
      };
      type = "nixosModules";
    };

  B =
    with inputs.haumea.lib;
    A.addLoadExtender {
      load.inputs = {
        inherit (inputs) dmerge;
      };
    };

  nixosModules =
    with inputs.haumea.lib;
    ((B.addLoadExtender {
      load = {
        src = ../evalModules/__fixture;
        type = "nixosModules";
      };
    }).addLoadExtender
      (
        extendPop pops.loadExtender (
          self: super: {
            load.inputs = {
              POP = inputs.POP;
            };
          }
        )
      )
    );
  inherit (builtins) deepSeq mapAttrs tryEval;
in
mapAttrs (_: x: tryEval (deepSeq x x)) {

  outputs = nixosModules.outputs { };

  exports = nixosModules.exports;
}
