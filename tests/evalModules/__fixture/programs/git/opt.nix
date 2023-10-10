{
  config.programs.git.__profiles__.name = "John Doe";
  options =
    with lib;
    (mkModulePath {
      __profiles__ = {
        enable = mkEnableOption (lib.mdDoc "Whether to enable git profile");
        name = lib.mkOption {
          type = types.str;
          default = "";
          description = "Your name";
        };
      };
    });
}
