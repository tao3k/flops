{
  root,
  POP,
  lib,
  yants,
  self,
}: let
  types = root.flake.types // yants;
  inherit (POP.lib) pop extendPop;
  inherit (yants) defun;
  inherit (lib) mapAttrs mergeToDepth foldl filter deSystemize;
in {
  inputsExtender = pop {
    defaults = {
      initInputs = {};
      inputs = {};
    };
    extension = self: super: {
      setInitInputs = defun (with types; [(attrs any) inputsExtenderPop]) (
        initInputs:
          extendPop self (self: super: {
            inherit initInputs;
          })
      );
    };
  };

  exporter = pop {
    defaults = {
      inputs = {};
      exports = {};
      # If system is empty (unchanged default) then exports will end up being system-spaced
      # and exporter will be called for all systems and inputs will be desystemized for each system.
      # If system is set to anything else, then exports will not be system-spaced and inputs
      # Examples:
      #   - a packages exporter should leave system as default
      #   - a nixosConfigurations should set the system to the one its exporting configs for
      #   - a lib export (with pure nix functions) could set the system to "-"
      system = "";
    };
    extension = self: super: {
      setInputs = defun (with types; [(attrs any) exporterPop]) (
        inputs:
          extendPop self (self: super: {
            inherit inputs;
          })
      );
      setSystem = defun (with types; [string exporterPop]) (
        system:
          extendPop self (self: super: {
            inherit system;
          })
      );
    };
  };

  default = pop {
    supers = [
      # Extend both pops and add apis for multiple extenders/exporters
      self.exporter
      self.inputsExtender
    ];
    defaults = {
      inputsExtenders = [];
      exporters = [];
    };
    extension = self: super: {
      inputs = let
        systemInputs = mapAttrs (_: input: deSystemize self.system input) self.initInputs;
      in
        foldl (cinputs: extender: mergeToDepth 3 cinputs (extender.setInitInputs systemInputs).inputs)
        systemInputs
        self.inputsExtenders;

      systemExporters = filter (exporter: exporter.system == "") self.exporters; # will be system-spaced
      generalExporters = filter (exporter: exporter.system != "") self.exporters; # not system-spaced, just top-level exports
      exports = let
        foldExporters = foldl (
          attrs: exporter:
            mergeToDepth 2 attrs (exporter.setInputs self.inputs).exports
        ) {};
      in {
        system = foldExporters self.systemExporters;
        general = foldExporters self.generalExporters;
      };

      addInputsExtenders = defun (with types; [(list inputsExtenderPop) flakePop]) (
        inputsExtenders:
          extendPop self (self: super: {
            inputsExtenders = super.inputsExtenders ++ inputsExtenders;
          })
      );
      addInputsExtender = defun (with types; [inputsExtenderPop flakePop]) (
        inputsExtender:
          self.addInputsExtenders [inputsExtender]
      );

      addExporters = defun (with types; [(list exporterPop) flakePop]) (
        exporters:
          extendPop self (self: super: {
            exporters = super.exporters ++ exporters;
          })
      );
      addExporter = defun (with types; [exporterPop flakePop]) (
        exporter:
          self.addExporters [exporter]
      );

      # Function to call at the end to get exported flake outputs
      outputsForSystem = defun (with types; [string (attrs any)]) (
        system: let
          inherit (self.setSystem system) exports;

          # Embed system into system-spaced exports
          systemSpacedExports = mapAttrs (_: export: {${system} = export;}) exports.system;
        in
          mergeToDepth 3 systemSpacedExports exports.general
      );
      outputsForSystems = defun (with types; [(list string) (attrs any)]) (
        systems:
          foldl (
            attrs: system:
              mergeToDepth 3 attrs (self.outputsForSystem system)
          ) {}
          systems
      );
    };
  };
}