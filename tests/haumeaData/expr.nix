{ inputs, lib }:
with inputs.haumea.lib;
let
  inherit (inputs) POP dmerge;
  inherit (POP.lib) extendPop;
  inherit (lib.haumea) pops;

  a = pops.default.setInit {
    transformer = [ transformers.liftDefault ];
    inputs = {
      lib = inputs.nixlib.lib;
    };
  };

  b = a.addLoadExtender {
    load = {
      inputs = {
        dmerge = inputs.dmerge;
      };
    };
  };

  data =
    ((b.addLoadExtender { load.src = ./__data; }).addLoadExtender (
      extendPop pops.loadExtender (
        self: super: { load.loader = [ (matchers.nix loaders.scoped) ]; }
      )
    )).addExporters
      [
        (extendPop pops.exporter (
          self: super: {
            exports.customData =
              with dmerge;
              self.outputs {
                treefmt.formatter.nix.excludes = append [ "data.nix" ];
                treefmt.formatter.prettier.includes = append [ "*.jsl" ];
              };
          }
        ))
      ];

  inherit (builtins) deepSeq mapAttrs tryEval;
in
mapAttrs (_: x: tryEval (deepSeq x x)) {
  outputs = {
    default = data.outputs { };
    dmergeWithOutputs = data.outputs {
      treefmt.formatter.nix.command = "nixfmt";
      treefmt.formatter.prettier.includes = with dmerge; append [ "*.dmergeOutputs" ];
    };
    funWithOutputs = data.outputs (
      x:
      x
      // {
        dataExt = {
          foo = "bar";
        };
      }
    );
  };
  exports = data.exports;
}
