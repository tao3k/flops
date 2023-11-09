{
  yants,
  root,
  super,
}:
with (yants "flops.haumea");
let
  inherit (super.structAttrs)
    haumeaLoadPop
    haumeaExporterPop
    haumeaInitLoadPop
    haumeaDefaultPop
    haumeaLoadExtender
    haumeaLoadExtenderPop
    pop
  ;
  inherit (haumeaInitLoadPop) initLoad;
in
{
  pop = openStruct pop;
  haumeaLoadExtender = struct "loadPop" haumeaLoadExtender;
  haumeaLoadExtenderPop = struct "loadExtenderPop" haumeaLoadExtenderPop;
  haumeaLoadPop = openStruct haumeaLoadPop;
  haumeaExporterPop = openStruct haumeaExporterPop;
  haumeaDefaultPop = openStruct haumeaDefaultPop;
  haumeaInitLoadPop = openStruct haumeaInitLoadPop;
  haumeaLoad = initLoad;
}
