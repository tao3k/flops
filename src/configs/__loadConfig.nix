{
  haumea,
  self,
}: options: let
  finalAttrs =
    if self.final != {}
    then self.final
    else self.loadConfig;
in
  if (options == "nixosModules")
  then {
    options = finalAttrs.options or [];
    imports = finalAttrs.imports or [];
    config = builtins.removeAttrs finalAttrs ["options" "imports"];
  }
  else finalAttrs
