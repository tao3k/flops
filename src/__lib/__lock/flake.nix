{
  inputs = {
    nosys.url = "github:divnix/nosys";
    flake-compat = {
      url = "github:gtrunsec/flake-compat/lockFile";
      flake = false;
    };
    call-flake.url = "github:divnix/call-flake";
  };
  outputs = _: { };
}
