{ inputs, lib }:
let
  inherit (lib) configs;
in
(
  (
    ((configs.pops.default.setInitRecipes { profiles = { }; }).addRecipesExtender {
      exx = {
        a = "2";
      };
    })
  ).addArgsExtender
  { nixos.default = { }; }
).addExporters
  [
    (inputs.POP.lib.extendPop configs.pops.exporter (
      self: super: { exports.nixos = self.recipes; }
    ))
  ]
