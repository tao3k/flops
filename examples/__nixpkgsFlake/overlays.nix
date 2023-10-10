inputs:
let
  inherit (inputs.POP.lib) kxPop extendPop;
in
pkgs: _: {
  helloPop = extendPop pkgs.hello (
    hello: super: {
      propagatedBuildInputs = super.propagatedBuildInputs ++ [ pkgs.curl ];

      attrs = extendPop super.drvAttrs (
        _: superAttrs: {
          src = extendPop superAttrs.src (
            params: superGL: { propagatedBuildInputs = [ pkgs.wget ]; }
          );
        }
      );
    }
  );
}
