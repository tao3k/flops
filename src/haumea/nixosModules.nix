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

  base =
    {
      extenders ? [ ],
    }:
    haumea.lib.load {
      inherit (cfg) src inputs;
      loader =
        inputs: path:
        (
          let
            module =
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
                    // (
                      {
                        cfg = l.attrByPath (relModulePathWithoutDefault path) { } config;
                        opt = l.attrByPath (relModulePathWithoutDefault path) { } options;
                        inherit mkModulePath;
                        moduleArgs = config._module.args // config._module.specialArgs;
                      }
                      //
                        l.optionalAttrs
                          (l.elem cfg.type [
                            "nixosModules"
                            "nixosProfiles"
                          ])
                          { pkgs = config._module.args.pkgs; }
                    )
                  );

                moduleArgs = baseModuleArgs // {
                  loadSubmodule =
                    path: (mkExtenders (builtins.scopedImport baseModuleArgs path) path);
                };

                callArgsLazily =
                  attrs: extraArgs:
                  if (l.isFunction attrs) then
                    lazyArgsPerParameter attrs (moduleArgs // extraArgs)
                  else
                    attrs
                ;

                s3 = callModuleLazily moduleArgs path;
                # => { config = { }; imports = [... ]; _file }
                s3final =
                  let
                    s3Module = mkExtenders (winnow path s3 mkModulePath) path;
                    s3Profile = mkExtenders s3 path;
                  in
                  if isModule then s3Module else s3Profile;

                mkExtenders =
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
                        extenders;

                    foundItem =
                      if (builtins.length filteredList) > 0 then
                        (builtins.head filteredList)
                      else
                        [ ]
                    ;

                    loadExtendModuleFromValue =
                      if foundItem != [ ] then
                        (callArgsLazily foundItem.value {
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
                        fun module.config
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
              in
              s3final;
          in
          module
        );
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
  __extenders = extenders: base { inherit extenders; };
}
// l.optionalAttrs (cfg.type == "nixosModules") { nixosModules = base { }; }
// l.optionalAttrs (cfg.type == "nixosProfiles") { nixosProfiles = base { }; }
