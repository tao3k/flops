inputs': let
  selfLib = inputs.haumea.lib.load {
    src = ./__lib;
    inputs = {
      lib = inputs.nixlib.lib;
    };
  };
  inputs = inputs' // {lib = inputs.nixlib.lib // selfLib;};
in
  selfLib
  // inputs.haumea.lib.load {
    src = ./.;
    inherit inputs;
  }
