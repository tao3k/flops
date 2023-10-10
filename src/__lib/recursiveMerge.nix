{ lib }:
let
  l = lib // builtins;
in
attrList:
let
  f =
    attrPath:
    builtins.zipAttrsWith (
      n: values:
      if l.tail values == [ ] then
        l.head values
      else if l.all l.isList values then
        l.unique (l.concatLists values)
      else if l.all l.isAttrs values then
        f [ n ] values
      else
        l.last values
    );
in
f [ ] attrList
