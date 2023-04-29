{
  lib,
  inputs,
}: let
  inherit (inputs) POP;
  inherit (lib.configs) pops;
  haumea =
    ((pops.haumea.setInit {
        src = ./__fixture;
        inputs = {};
        transformer = with inputs.haumea.lib.transformers; [
          liftDefault
        ];
      })
      .addInputs {
        lib = inputs.nixlib.lib;
      })
    .addTransformer (with inputs.haumea.lib.transformers; [
      (hoistLists "_imports" "imports")
      (hoistAttrs "_options" "options")
    ]);
in
  haumea.outputs {nixosModules = true;}
