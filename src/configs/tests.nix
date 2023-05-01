{
  haumea,
  lib,
  root,
  self,
}: let
  inherit (root) pops;
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
  haumeaNixOSModules.outputs { nixosModules = true;}
   => { options = {...}, imports = [...], config = {...} }
  */
  haumeaNixOSModules =
    ((root.haumea.setInit {
        src = ./recipes/nixosModules;
        inputs = {};
        transformer = with haumea.lib.transformers; [
          liftDefault
        ];
      })
      .addInputs {
        inherit lib;
      })
    .addTransformer
    (with haumea.lib.transformers; [
      (hoistLists "_imports" "imports")
      (hoistAttrs "_options" "options")
    ]);
in {
  inherit haumeaNixOSModules nixosProfiles;

  eval = lib.evalModules {
    modules = [
      (
        {...} @ args:
          (haumeaNixOSModules.addInputs args).outputs {nixosModules = true;}
        # pops = (config.pops.addConfigsExtenders [
        # (POP.lib.extendPop pops.ConfigsExtender (self: super: {
        #  configs.nixos = custom self.args.nixos;
        # }
        #]
        # addArgsExtenders [
        # (POP.lib.extendPop pops.ArgsExtender (self: super: {
        # args.nixos = args //
        #  set the specialArgs to the nixos
        # { specialArgs_1 = "1"; };
        # )))
        #];
        # custom' = pops.feeders.nixos pops.args.nixos.default;
        # custom'-home = pops.feeders.home-manager.common pops.args.home-manager.common;
      )
    ];
  };
}
