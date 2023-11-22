{ inputs, lib }:
with inputs.haumea.lib;
let
  l = lib // builtins;
  trace = x: l.trace x x;
  inherit (inputs) dmerge;
  inherit (inputs.POP.lib) pop extendPop kxPop;
  inherit (lib.haumea) pops;

  a =
    (pops.default.setInit {
      src = ./.;
      inputs = {
        inherit lib;
      };
    }).addLoadExtender
      (
        extendPop pops.loadExtender (
          self: super: {
            load.inputs = {
              inherit inputs;
            };
          }
        )
      );

  b = a.addLoadExtender {
    load = {
      src = ../..;
      loader = [ (matchers.nix loaders.scoped) ];
      inputs = {
        inherit dmerge;
      };
    };
  };

  b1 = b.addLoadExtender {
    load = {
      inputs = {
        a = "1";
      };
      src = ../tests/haumeaData/__data;
    };
  };

  c =
    ((b.addLoadExtender {
      load.src = ../tests/haumeaData/__data;
      load.inputsTransformer = [ (x: (x // { a = "1"; })) ];
    }).addLoadExtender
      (
        extendPop pops.loadExtender (
          self: super: {
            load = {
              loader = [ (matchers.nix loaders.scoped) ];
            };
          }
        )
      )
    ).addExporters
      [
        (extendPop pops.exporter (
          self: super: {
            exports.a = self;
            # exports.mergedOutputs =
            #   with dmerge;
            #   merge self.outputs.default {
            #     treefmt.formatter.prettier.includes = append [ "*.jsl" ];
            #     data.foo = "barzf";
            #   };
          }
        ))
      ];

  # d = c.addExporters [
  #   (extendPop pops.exporter (
  #     self: super: { exports.mergedPrevOutputs = self.exports; }
  #   ))
  # ];
  #
  d = c.addLoadExtender {
    loader = [ (matchers.nix loaders.scoped) ];
    inputs = {
      inherit (inputs) nixlib;
    };
  };

  g =
    (pops.default.setInit {
      src = ../tests/evalModules/__fixture;
      type = "nixosModules";
      inputs = {
        inherit lib POP;
      };
    }).addExporters
      [
        (extendPop pops.exporter (
          self: super: {
            exports.customModules = self.outputs [ {
              value =
                { selfModule' }:
                selfModule' (
                  m:
                  dmerge m {
                    config.services.openssh.enable = false;
                    config.services.openssh.customList = with dmerge; append [ "1" ];
                    imports = with dmerge; append [ ];
                  }
                );
              path = [
                "services"
                "openssh"
              ];
            } ];
          }
        ))
      ];

  evalModules = l.evalModules {
    modules = [
      g.exports.customModules.services.openssh
      # g.outputs.default.programs.emacs
      # g.outputs.default.programs.git
    ];
  };

  mkOpt = {
    type = "string";
    default = x;
  };
in
{
  inherit
    a
    b
    c
    d
    g
    h
    evalModules
    loadd
    b1
  ;
  options = mkOpt { test = "1"; };
}
