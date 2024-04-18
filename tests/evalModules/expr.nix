{ lib, inputs }:
let
  inherit (inputs) POP dmerge nixlib;
  inherit (POP.lib) extendPop;
  inherit (lib.haumea) pops;
  inherit (nixlib.lib) evalModules;

  A =
    with inputs.haumea.lib;
    pops.default.setInit {
      src = ../..;
      type = "default";
    };

  B =
    with inputs.haumea.lib;
    A.addLoadExtender {
      load.inputs = {
        POP = inputs.POP;
        lib = inputs.nixlib.lib;
        inherit (inputs) dmerge;
      };
    };

  loadModules =
    (B.addLoadExtender {
      load = {
        src = ./__fixture;
        type = "nixosModules";
      };
    }).addExporters
      [
        (extendPop pops.exporter (
          self: super: {
            exports.test = self.outputs [
              ({
                value = (
                  { selfModule' }:
                  selfModule' (m: dmerge m { config.programs.git.__profiles__.enable = false; })
                );
                path = [
                  "programs"
                  "git"
                ];
              })
              ({
                value = (
                  { selfModule' }:
                  selfModule' (
                    m: dmerge m { config.programs.git.__profiles__.name = "guangtao"; }
                  )
                );
                path = [
                  "programs"
                  "git"
                  "opt"
                ];
              })
            ];
          }
        ))
      ];

  evaled = {
    default =
      (evalModules {
        modules = [
          loadModules.layouts.default.programs.git
          loadModules.layouts.default.programs.emacs
          loadModules.layouts.default.services.openssh
        ];
      }).config;
    custom =
      (evalModules {
        modules = [
          loadModules.exports.test.programs.git
          # loadModules.outputs.default.programs.git
        ];
      }).config;
  };
  inherit (builtins) deepSeq mapAttrs tryEval;
in
evaled
