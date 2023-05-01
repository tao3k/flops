{
  haumea,
  self,
}: options: let
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
  else loadConfig
