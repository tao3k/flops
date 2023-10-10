{ yants, root }:
let
  types = root.configs.types // yants;

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
  };
in
structAttrs
