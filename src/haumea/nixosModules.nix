{
  haumea,
  lib,
  dmerge,
}:
{ cfg }:
let
  l = lib // builtins;
  trace = x: l.traceSeq x x;
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

  callModuleLazily =
    inputs: path:
    let
      importer = l.scopedImport inputs;
      f = toFunction (importer path);
    in
    lazyArgsPerParameter f inputs;

  callModuleLazily' =
    inputs: path: importer:
    let
      f = toFunction (importer path);
    in
    lazyArgsPerParameter f inputs;

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
      false
  ;

  base =
    {
      extender ? [ ],
    }:
    haumea.lib.load {
      inherit (cfg) src inputs;
      loader =
        with haumea.lib;
        [
          (matchers.nix (
            inputs: path:
            (
              let
                module =
                  if (isTopLevel path) && cfg.type == "nixosProfilesOmnibus" then
                    callModuleLazily inputs path
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
                      baseModuleArgs =
                        (
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
                        loadSubmodule = path: (mkExtender (callModuleLazily baseModuleArgs path) path);
                      };

                      mkExtender =
                        module: path:
                        let
                          removedOptionModule = removeAttrs module [ "options" ];
                          filteredList =
                            l.filter
                              (
                                item:
                                item.path == (
                                  if isModule then relModulePathWithoutDefault path else relModulePath path
                                )
                              )
                              extender;

                          foundItem =
                            if (builtins.length filteredList) > 0 then
                              (builtins.head filteredList)
                            else
                              [ ]
                          ;

                          callValueModuleLazily =
                            v: extraArgs:
                            if (l.isFunction v) then
                              lazyArgsPerParameter v (moduleArgs // extraArgs)
                            else if (l.isPath v) then
                              callModuleLazily' (moduleArgs // extraArgs) v import
                            else
                              v
                          ;

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
                              module
                          ;
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
                              )
                          ;
                          imports = module.imports or [ ];
                        })
                        // {
                          _file = path;
                          options = fun module.options or { };
                        }
                      ;

                      callDefaultModule = callModuleLazily moduleArgs path;
                      # => { config = { }; imports = [... ]; _file }
                      finalModule =
                        let
                          extendedModule = mkExtender (winnow path callDefaultModule mkModulePath) path;
                          extendedProfile = mkExtender callDefaultModule path;
                        in
                        if isModule then extendedModule else extendedProfile;
                    in
                    finalModule
                ;
              in
              module
            )
          ))
        ]
        ++ (lib.optionals (lib.isList cfg.loader)) cfg.loader
      ;
      transformer =
        if cfg.transformer != [ ] then
          cfg.transformer
        else
          [ (_cursor: dir: if dir ? default then dir.default else dir) ]
      ;
    };
in
{
  default = base { };
  __extender = extender: base { inherit extender; };
}
