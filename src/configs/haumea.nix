{
  POP,
  haumea,
  yants,
  root,
}: let
  inherit (POP.lib) pop extendPop;
  inherit (yants) defun;
  types = yants // root.configs.types;
in
  pop {
    defaults = {
      outputs = {};
      transformer = [];
      inputs = {};
      init = {
        src = ./.;
        load = haumea.lib.loaders.default;
        transformer = [];
        inputs = {};
      };
    };
    extension = self: super: {
      setInit = defun (with types; [(attrs any) haumeaPop]) (setInit:
        extendPop self (self: super: {
          init = super.init // setInit;
        }));
      outputsForTarget = defun (with types; [haumeaOptions (attrs any)]) (
        import ./__loadConfig.nix {inherit haumea self;}
      );
      addTransformer = defun (with types; [(list function) haumeaPop]) (
        transformer:
          extendPop self (self: super: {
            transformer = super.transformer ++ transformer;
          })
      );
      addInputs = defun (with types; [(attrs any) haumeaPop]) (
        inputs:
          extendPop self (self: super: {
            inputs = super.inputs // inputs;
          })
      );
    };
  }
