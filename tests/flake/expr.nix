{
  lib,
  inputs,
  flake,
}:
let
  inherit (builtins) deepSeq mapAttrs tryEval;

  inherit (inputs) POP;
  inherit (flake) pops;
  exampleFlake = {
    inherit inputs;
    outputs =
      inputs:
      (
        ((pops.default.setInitInputs inputs).addInputsExtenders [
          (POP.lib.extendPop pops.inputsExtender (
            self: super: {
              inputs = {
                inherit ((inputs.call-flake ../../examples/__nixpkgsFlake).inputs) nixpkgs;
                nixlib.lib.func = self.initInputs.nixlib.lib.genAttrs;
              };
            }
          ))
        ]).addExporters
        [
          (POP.lib.extendPop pops.exporter (
            self: _: { exports.packages.firefox = self.inputs.nixpkgs.firefox; }
          ))
        ]
      ).outputsForSystems
        [
          "x86_64-linux"
          "x86_64-darwin"
        ];
  };
  outputs =
    inputs:
    (
      (
        ((pops.default.setInitInputs inputs).setSystem "x86_64-linux")
        .addInputsExtenders
        [
          {
            inputs = {
              nixlib.lib.func = lib.isFunction;
            };
          }
        ]
      )
    ).inputs;
in
{
  exampleFlake = exampleFlake.outputs exampleFlake.inputs;
  inputs = outputs ./__lock;
}
