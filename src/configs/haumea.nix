{
  POP,
  haumea,
  yants,
  root,
  lib,
  dmerge,
}: let
  inherit (POP.lib) pop extendPop;
  inherit (yants) defun;
  types = yants // root.configs.types;
in
  pop {
    defaults = {
      transformer = [];
      inputs = {};
      init = {
        src = ./.;
        load = haumea.lib.loaders.default;
        transformer = [];
        inputs = {};
      };
      final = {};
    };
    extension = self: super: {
      setInit = defun (with types; [(attrs any) haumeaPop]) (setInit:
        extendPop self (self: super: {
          init = super.init // setInit;
        }));
      outputsForTarget = defun (with types; [haumeaOptions (attrs any)]) (
        import ./__loadConfig.nix {inherit haumea self;}
      );
      addTransformer = defun (with types; [(list any) haumeaPop]) (
        transformer:
          extendPop self (self: super: {
            transformer = super.transformer ++ transformer;
          })
      );

      loadConfig = haumea.lib.load {
        src = self.init.src;
        loader = self.init.load;
        transformer = self.init.transformer ++ self.transformer;
        inputs = self.init.inputs // self.inputs;
      };

      addMerge = attrs:
        extendPop self (self: super: {
          final =
            if super.final == {}
            then (attrs self.loadConfig)
            else (attrs super.final);
        });

      addInputs = defun (with types; [(attrs any) haumeaPop]) (
        inputs:
          extendPop self (self: super: {
            inputs = super.inputs // inputs;
          })
      );
    };
  }
