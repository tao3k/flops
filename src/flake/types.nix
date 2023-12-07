{ yants, super }:
with (yants "flops"); {
  pop = openStruct super.structAttrs.pop;
  exporterPop = openStruct super.structAttrs.exporterPop;

  inputsExtenderPop =
    openStruct "inputsExtenderPop"
      super.structAttrs.inputsExtenderPop;
  inputsExtender = struct "inputsExtender" super.structAttrs.inputsExtender;

  flakePop = openStruct super.structAttrs.flakePop;
}
