{ configs, inputs }:
let
  inherit (inputs) POP dmerge;
  default =
    (
      (configs.pops.default.setInitRecipes {
        nixos = {
          modules = [ ];
        };
      }).addRecipesExtender
      {
        home-manager = {
          modules = [ ];
        };
      }
    ).addExporters
      [
        (inputs.POP.lib.extendPop configs.pops.exporter (
          self: super: {
            exports.home-manager = self.recipes.home-manager;
            exports.nixos = self.recipes.nixos;
          }
        ))
      ];
  inherit (builtins) deepSeq mapAttrs tryEval;
in
mapAttrs (_: x: tryEval (deepSeq x x)) {
  home-manager = default.exports.home-manager;
  nixos = default.exports.nixos;
}
