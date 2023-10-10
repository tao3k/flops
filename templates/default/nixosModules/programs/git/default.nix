{
  enable = true;

  options = {
    custom = lib.mkOption {
      type = lib.types.str;
      default = "default";
    };
  };
}
