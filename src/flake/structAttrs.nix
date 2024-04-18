{ yants, root }:
let
  types = root.flake.types // yants;
  structAttrs = with yants; {
    pop = {
      __meta__ = option (
        struct "__meta__" {
          name = string;
          supers = list types.pop;
          defaults = attrs any;
          extension = function;
          precedenceList = list (attrs any);
        }
      );
    };

    exporterPop = structAttrs.pop // {
      inputs = attrs any;
      exports = attrs any;
      setInputs = function;
      setSystem = function;
    };

    inputsExtenderPop = structAttrs.pop // {
      initInputs = attrs any;
      initFlake = attrs any;
      sysInputs = attrs any;
      inputs = attrs any;
      setInitInputs = function;
    };

    inputsExtender = {
      inputs = attrs any;
    };

    flakePop =
      structAttrs.exporterPop
      // structAttrs.inputsExtenderPop
      // {
        exporters = list types.exporterPop;

        system = string;

        exports = attrs any;
        initInputs = attrs any;
        inputs = attrs any;
        # without deSystemize
        sysInputs = attrs any;

        addInputsExtenders = function;
        addInputsExtender = function;
        addExporters = function;
        addExporter = function;
      };
  };
in
structAttrs
