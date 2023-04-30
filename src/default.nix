inputs': let
  selfLib = inputs.haumea.lib.load {
    src = ./lib;
    inputs = {
      lib = inputs.nixlib.lib;
    };
  };
  inputs = inputs' // {lib = inputs.nixlib.lib // selfLib;};
in
  selfLib
  // {
    flake = with inputs.haumea.lib;
      load {
        src = ./flake;
        inherit inputs;
      };

    configs = with inputs.haumea.lib;
      load {
        src = ./configs;
        inherit inputs;
      };
  }
