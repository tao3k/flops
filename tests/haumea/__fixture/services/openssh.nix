{
  enable = true;
  _imports = [];
  _options = {
    description = ''
      Options to pass to the import.
    '';
  };
  # _options = lib.mkOption {
  #   type = lib.types.submodule {
  #     freeformType = lib.types.attrs;
  #     options = {
  #       endpoint = lib.mkOption {
  #         type = lib.types.str;
  #         default = "localhost:5158";
  #         description = "The endpoint at which the VAST node is listening.";
  #       };
  #     };
  #   };
  # };
}
