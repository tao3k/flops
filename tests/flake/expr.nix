{
  pops,
  inputs,
}: let
  inherit (inputs) POP;
  exampleFlake = {
    inherit inputs;
    outputs = inputs:
      (
        (
          (
            pops.flake.setInitInputs inputs
          )
          .addInputsExtenders [
            (POP.lib.extendPop pops.inputsExtender (self: super: {
              inputs = {
                nixlib.lib.func = self.initInputs.nixlib.lib.genAttrs;
              };
            }))
          ]
        )
        .addExporters [
          (POP.lib.extendPop pops.exporter (self: _: {
            exports.packages.firefox = self.inputs.nixpkgs.legacyPackages.firefox;
          }))
        ]
      )
      .outputsForSystems ["x86_64-linux" "x86_64-darwin"];
  };
in
  exampleFlake.outputs exampleFlake.inputs
