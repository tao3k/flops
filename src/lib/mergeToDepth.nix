{
  lib,
  root,
}: let
  inherit (lib) mapAttrs isAttrs;

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
in
  mergeToDepth
