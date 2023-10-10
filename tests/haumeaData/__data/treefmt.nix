{
  formatter.nix = {
    command = "alejandra";
    excludes = [ ];
  };
  prettier = {
    includes = [ "*.toml" ];
  };
}
