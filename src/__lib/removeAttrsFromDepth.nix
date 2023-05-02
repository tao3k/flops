{
  lib,
  super,
}: from: let
  inherit
    (lib)
    recursiveUpdate
    ;
  inherit
    (super)
    concatMapAttrsWith
    ;

  getPath = l: n: lib.elemAt l n;
in
  cursor:
    concatMapAttrsWith recursiveUpdate
    (file: value:
      if file == getPath from 0 && lib.length from == 1
      then {}
      else if file == getPath from 0 && (lib.hasAttr (getPath from 1) value)
      then {${file} = removeAttrs value [(getPath from 1)];}
      else {
        ${file} = value;
      })
