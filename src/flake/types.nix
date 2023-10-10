{ yants, root }:
with (yants "flops"); {
  pop = openStruct root.flake.structAttrs.pop;
  exporterPop = openStruct root.flake.structAttrs.exporterPop;
  inputsExtenderPop = openStruct root.flake.structAttrs.inputsExtenderPop;
  flakePop = openStruct root.flake.structAttrs.flakePop;
}
