{
  inputs = {
    flake-compat = {
      url = "github:gtrunsec/flake-compat/lockFile";
      flake = false;
    };
  };
  outputs = { self, ... }@inputs: { inherit inputs; };
}
