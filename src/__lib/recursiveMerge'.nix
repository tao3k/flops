{ lib, ... }:

with lib;

let
  recursiveMerge =
    attrList:
    let
      f =
        attrPath:
        zipAttrsWith (
          n: values:
          if tail values == [ ] then
            head values
          else if all isList values then
            unique (foldr (acc: val: val ++ acc) [ ] values) # Reverse the order of concatenation
          else if all isAttrs values then
            f (attrPath ++ [ n ]) values
          else
            last values
        );
    in
    f [ ] attrList;
in
recursiveMerge
