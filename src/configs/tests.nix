{
  haumea,
  lib,
  root,
  self,
  POP,
  dmerge,
}: let
  inherit (root.configs) pops;
  /*
  nixosProfiles.outputs {}
  => { hom-manager = { ... }; nixos = { ... }; }
  */
  nixosProfiles = root.haumea.setInit {
    src = ./recipes/nixosProfiles;
    transformer = with haumea.lib.transformers; [];
    inputs = {inherit lib;};
  };
  /*
  haumeaNixOSModules.outputsForTarget "nixosModules"
   => { options = {...}, imports = [...], config = {...} }
  */
  haumeaNixOSModules =
    ((((root.configs.haumea.setInit {
            src = ./recipes/nixosModules;
            inputs = {};
            transformer = with haumea.lib.transformers; [
              liftDefault
              (lib.removeAttrsFromDepth ["services" "openssh"])
            ];
          })
          .addInputs {
            inherit lib;
          })
        .addTransformer
        (with haumea.lib.transformers; [
          (hoistLists "_imports" "imports")
          (hoistAttrs "_options" "options")
        ]))
      .addMerge (final:
        lib.recursiveUpdate final {
          services.openssh.enable = false;
        }))
    .addMerge (
      final:
        lib.recursiveUpdate final {
          services.openssh = {
            customOp = "append";
          };
        }
    );
in {
  inherit haumeaNixOSModules nixosProfiles;

  configs =
    (((pops.default.setInitRecipes
          {
            nixos.default = haumeaNixOSModules;
          })
        .addArgsExtender
        {
          nixos.default = {inherit haumea;};
        })
      .addRecipesExtender {
        home-manager = {};
      })
    .addExporters [
      (POP.lib.extendPop pops.exporter (self: super: {
        exports.test = {
          r = self.recipes;
          args = self.args;
        };
      }))
    ];

  eval = lib.evalModules {
    modules = [
      (
        {...} @ args:
        # (haumeaNixOSModules.addInputs args).outputsForTarget "nixosModules";
          (((pops.default.setInitRecipes
                {
                  nixos.default = haumeaNixOSModules;
                })
              .addArgsExtender
              {
                nixos.default = args;
              })
            .addExporters [
              (POP.lib.extendPop pops.exporter (self: super: {
                exports.nixos = (self.recipes.nixos.default.addInputs self.args.nixos.default).outputsForTarget "nixosModules";
              }))
            ])
          .exports
          .nixos
      )
    ];
  };
}
