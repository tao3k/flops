{lib}:{
  enable = true;
  _options = lib.mkOption {
    type = lib.types.submodule {
      freeformType = lib.types.attrs;
      options = {
        enable = lib.mkEnableOption (lib.mdDoc "Whether to enable greetd profile");
      };
    };
  };
}
