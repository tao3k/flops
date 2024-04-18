{
  haumea,
  lib,
  dmerge,
}:
cfg: extender: importer:
let
  l = lib // builtins;
  inherit (builtins) mapAttrs;
  inherit (lib) functionArgs pipe toFunction;

  isModule = l.elem cfg.type [
    "nixosModules"
    "evalModules"
  ];

  isProfile = l.elem cfg.type [ "nixosProfiles" ];

  lazyArgsPerParameter =
    f: inputs:
    pipe f [
      functionArgs
      (mapAttrs (name: _: inputs.${name}))
      f
    ];

  importModule = importer;

  removeFileSuffix = l.removeSuffix ".nix";
  removeDefault = l.removeSuffix "/default";
  relModulePathWithoutDefault = relModulePathWithoutDefault' removeDefault;
  relModulePath = relModulePathWithoutDefault' l.id;
  relModulePathWithoutDefault' =
    extraFun: path:
    (l.drop 1 (
      l.splitString "/" (
        extraFun (removeFileSuffix (l.last (l.splitString cfg.src (toString path))))
      )
    ));

  isTopLevel =
    path:
    if
      l.length (l.splitString "/" (l.last (l.splitString cfg.src (toString path))))
      == 2
    then
      true
    else
      false;
in

(
  inputs: path:
  (
    let
      module =
        if (isTopLevel path) && cfg.type == "nixosProfilesOmnibus" then
          importModule inputs path
        else
          {
            config ? { },
            options ? { },
            ...
          }@args:
          let
            mkModulePath =
              attrs': l.setAttrByPath (relModulePathWithoutDefault path) attrs';
            test = config._module.args.pkgs or { };
            baseModuleArgs = (
              inputs
              // args
              // ({
                cfg = l.attrByPath (relModulePathWithoutDefault path) { } config;
                opt = l.attrByPath (relModulePathWithoutDefault path) { } options;
                inherit mkModulePath;
                moduleArgs = config._module.args // config._module.specialArgs;
                # override the self for the module
                self = inputs.self { };
                pkgs = config._module.args.pkgs;
              })
            );

            moduleArgs = baseModuleArgs // {
              loadSubmodule = path: (mkExtender (importModule baseModuleArgs path) path);
            };

            mkExtender =
              module: path:
              let
                removedOptionModule = removeAttrs module [ "options" ];
                filteredList = l.filter (
                  item:
                  item.path
                  == (if isModule then relModulePathWithoutDefault path else relModulePath path)
                ) extender;

                foundItem =
                  if (builtins.length filteredList) > 0 then
                    (builtins.head filteredList)
                  else
                    [ ];

                callValueModuleLazily =
                  v: extraArgs:
                  if (l.isFunction v) then
                    lazyArgsPerParameter v (moduleArgs // extraArgs)
                  else if (l.isPath v) then
                    importModule (moduleArgs // extraArgs) v
                  else
                    v;

                loadExtendModuleFromValue =
                  if foundItem != [ ] then
                    (callValueModuleLazily foundItem.value {
                      selfModule = module;
                      # add the options back in
                      # dmerge self' {}
                      selfModule' = x: module // (x removedOptionModule);
                      # add dmerge support
                      inherit dmerge;
                    })
                  else
                    module;
              in
              loadExtendModuleFromValue;

            winnow =
              path: module: fun:
              ({
                config =
                  if module ? config then
                    module.config
                  else
                    fun (
                      removeAttrs module [
                        "options"
                        "imports"
                      ]
                    );
                imports = module.imports or [ ];
              })
              // {
                _file = path;
                options = fun module.options or { };
              };

            callDefaultModule = importModule moduleArgs path;
            # => { config = { }; imports = [... ]; _file }
            finalModule =
              let
                extendedModule = mkExtender (winnow path callDefaultModule mkModulePath) path;
                extendedProfile = mkExtender (winnow path callDefaultModule lib.id) path;
              in
              if isModule then extendedModule else extendedProfile;
          in
          finalModule;
    in
    module
  )
)
