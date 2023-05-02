{
  lib,
  super,
}: from:
# Example from / to
# - Lifting `options` from: _api, to: options
#
# Note:
#   underscore used as mere convention to signalling to the user the  "private"
#   nature, they won't be part of the final view presented to the user
let
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
