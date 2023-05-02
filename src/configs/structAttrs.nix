{
  yants,
  root,
}: let
  types = root.configs.types // yants;

  structAttrs = with yants; {
    pop = {
      __meta__ = option (struct "__meta__" {
        name = string;
        supers = list types.pop;
        defaults = attrs any;
        extension = function;
        precedenceList = list (attrs any);
      });
    };

    haumeaPop =
      structAttrs.pop
      // rec {
        inputs = attrs any;
        final = attrs any;
        init = struct "haumea.load" {
          src = either path string;
          transformer = transformer;
          inputs = inputs;
          load = function;
        };
        transformer = list any; #list (either function any);

        setInit = function;

        addTransformer = function;
        addInputs = function;
      };

    haumeaOptions = enum "options" ["nixosModules" "default"];
  };
in
  structAttrs
