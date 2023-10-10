{
  lib,
  inputs,
  self,
}:
let
  inherit (inputs) POP;
  inherit (lib) flake;
in
{
  a =
    ((((flake.pops.default.setInitInputs ./__nixpkgsFlake).setSystem "x86_64-linux")
    .addInputsExtender
      (
        POP.lib.extendPop flake.pops.inputsExtender (
          self: super: {
            inputs.nixlib = inputs.nixlib;
            inputs.b = throw "should not be evaluated";
            inputs.custom = self.inputs.nixlib;
          }
        )
      )
    ).addInputsOverrideExtender
      (
        POP.lib.extendPop flake.pops.inputsExtender (
          self: super: { overrideInputs.std = "s"; }
        )
      )
    );

  b = self.a.addInputsExtender (
    POP.lib.extendPop flake.pops.inputsExtender (self: super: { inputs.b = "2"; })
  );
}
