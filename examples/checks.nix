{
  inputs,
  configs,
  lib,
}:
inputs.haumea.lib.load {
  src = ../tests;
  inputs = {
    inherit inputs configs lib;
  };
}
