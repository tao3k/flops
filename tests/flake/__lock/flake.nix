{
  inputs = {
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };
  outputs =
    { self, ... }@inputs:
    {
      inherit inputs;
    };
}
