{yants, root}:
with (yants "flops"); {
  pop = openStruct root.structAttrs.pop;
  exporterPop = openStruct root.structAttrs.exporterPop;
  inputsExtenderPop = openStruct root.structAttrs.inputsExtenderPop;
  flakePop = openStruct root.structAttrs.flakePop;
}
