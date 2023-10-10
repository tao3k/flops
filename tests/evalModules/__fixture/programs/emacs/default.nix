{
  /* # we can also use the following syntax to define a module
     config = {
      enable = true;
      }
  */

  enable = true;
  customAttr2 = config.programs.emacs.customAttr;
  customList2 = cfg.customList ++ [ "b" ];
  options = lib.mkOption {
    type = lib.types.submodule {
      freeformType = lib.types.attrs;
      options = {
        enable = lib.mkEnableOption {
          default = true;
          description = "Whether to enable the VAST node.";
        };
        customAttr = lib.mkOption {
          type = lib.types.attrs;
          default = {
            a = "a";
          };
          description = "A custom attribute.";
        };
        customAttr2 = lib.mkOption {
          type = lib.types.attrs;
          default = { };
          description = "A custom attribute.";
        };
        customList = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ "a" ];
          description = "A custom list.";
        };
        customList2 = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "A custom list.";
        };
      };
    };
  };
}
