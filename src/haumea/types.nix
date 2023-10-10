{
  yants,
  root,
  super,
}:
with (yants "flops");
let
  inherit (super.structAttrs)
    haumeaLoadPop
    haumeaExporterPop
    haumeaInitLoadPop
    haumeaDefaultPop
    pop
  ;
  inherit (haumeaInitLoadPop) initLoad;
in
{
  pop = openStruct pop;
  haumeaLoadPop = openStruct haumeaLoadPop;
  haumeaExporterPop = openStruct haumeaExporterPop;
  haumeaDefaultPop = openStruct haumeaDefaultPop;
  haumeaInitLoadPop = openStruct haumeaInitLoadPop;
  haumeaLoad = initLoad;
}
