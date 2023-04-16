inputs': let
  inherit (inputs.POP.lib) pop unpop extendPop kxPop;
  inherit (inputs.lib) mapAttrs isAttrs mergeToDepth;
  inputs =
    inputs'
    // {
      lib =
        inputs.nixlib.lib
        // {
          deSystemize = import ./de-systemize.nix;
          mergeToDepth = depth: lhs: rhs:
            if depth == 1
            then lhs // rhs
            else
              lhs
              // (mapAttrs (
                  n: v:
                    if isAttrs v
                    then mergeToDepth (depth - 1) (lhs.${n} or {}) v
                    else v
                )
                rhs);
        };
    };
in {
  flake = with inputs.haumea.lib;
    load {
      src = ./flake;
      inherit inputs;
    };
}
