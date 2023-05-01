{
  yants,
  root,
}:
with (yants "flops"); {
  pop = openStruct root.configs.structAttrs.pop;
  haumeaPop = openStruct root.configs.structAttrs.haumeaPop;
  haumeaOptions = root.configs.structAttrs.haumeaOptions;
}
