{
  haumea,
  lib,
  dmerge,
  super,
}:
{ cfg, initLoad }:
let
  l = lib // builtins;

  base =
    {
      extender ? [ ],
    }:
    haumea.lib.load {
      inherit (cfg) src inputs;
      loader =
        with haumea.lib;
        (lib.optionals (initLoad.loader != haumea.lib.loaders.default) [
          (matchers.nix (super.importModule cfg extender cfg.nixosModuleImporter))
        ])
        ++ (lib.optionals (lib.isList cfg.loader)) cfg.loader;
      transformer =
        if cfg.transformer != [ ] then
          cfg.transformer
        else
          [ (_cursor: dir: if dir ? default then dir.default else dir) ];
    };
in
{
  default = base { };
  __extender = extender: base { inherit extender; };
}
