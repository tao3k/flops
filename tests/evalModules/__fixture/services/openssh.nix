{
  lib,
  config,
  cfg,
}:
{
  enable = true;
  enableCustom = cfg.enable;
  customList = [ "a" ];
  customList2 = [ ];
  customList3 = [ ];
  customList4 = [ "mkMerge" ];

  options = lib.mkOption {
    type = lib.types.submodule {
      freeformType = lib.types.attrs;
      options = {
        enableCustom = lib.mkEnableOption {
          default = false;
          description = "Whether to enable the custom node.";
        };
        enable = lib.mkEnableOption {
          default = true;
          description = "Whether to enable the VAST node.";
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

        customList3 = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "A custom list.";
        };
        customList4 = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "A custom list.";
        };
      };
    };
  };
}
