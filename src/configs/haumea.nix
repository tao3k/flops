{
  POP,
  haumea,
}: let
  inherit (POP.lib) pop extendPop;
in
  pop {
    defaults = {
      outputs = {};
      transformer = [];
      inputs = {};
      init = {
        src = ./.;
        load = haumea.lib.loaders.default;
        transformer = with haumea.lib.transformers; [
          (hoistLists "_imports" "imports")
          (hoistAttrs "_options" "options")
        ];
        nixosModules = false;
      };
    };
    extension = self: super: {
      setInit = setInit:
        extendPop self (self: super: {
          init = super.init // setInit;
        });
      outputs = options: let
        loadConfig = haumea.lib.load {
          src = self.init.src;
          loader = self.init.load;
          transformer = self.init.transformer ++ self.transformer;
          inputs = self.init.inputs // self.inputs;
        };
      in
        if (options ? nixosModules && options.nixosModules)
        then {
          inherit (loadConfig) options imports;
          config = builtins.removeAttrs loadConfig ["options" "imports"];
        }
        else loadConfig;

      addTransformer = (
        transformer:
          extendPop self (self: super: {
            transformer = super.transformer ++ transformer;
          })
      );
      addInputs = (
        inputs:
          extendPop self (self: super: {
            inputs = super.inputs // inputs;
          })
      );
    };
  }
