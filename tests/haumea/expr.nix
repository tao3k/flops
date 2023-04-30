{
  lib,
  inputs,
}: let
  inherit (inputs) POP;
  inherit (lib.configs) haumea;
  nixosModules =
    ((haumea.setInit {
        src = ./__fixture;
        inputs = {
          POP = inputs.POP;
        };
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
  nixosModules.outputs {nixosModules = true;}
