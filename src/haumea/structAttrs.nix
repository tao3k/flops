{
  yants,
  root,
  lib,
  self,
}:
let
  types = root.haumea.types // yants;
  l = lib // builtins;

  enum' =
    o: e: v:
    (with yants; enum o e)
    // {
      toError =
        x:
        throw ''
          Invalid value for '${v}': "${x}"
          Valid values are: [ ${l.concatStringsSep " " e} ]
        '';
    }
  ;
  structAttrs = with yants; {
    pop = {
      __meta__ = option (
        struct "__meta__" {
          name = string;
          supers = list types.pop;
          defaults = attrs any;
          extension = function;
          precedenceList = list (attrs any);
        }
      );
    };

    haumeaDefaultPop = structAttrs.pop // {
      exports = attrs any;

      loadExtenders = list any;

      addLoadExtender = function;
      addLoadExtenders = function;

      addExporters = function;
      addExporter = function;
      load = attrs any;
      initLoad = struct "haumea.load" structAttrs.haumeaLoad;

      outputs = function;
      layouts = attrs any;
    };

    haumeaExporterPop = structAttrs.pop // {
      exports = attrs any;
      load = attrs any;

      setLoad = function;
      setOutputs = function;
    };
    haumeaLoad = {
      src = either path string;
      transformer = either function (list any);
      inputsTransformer = either function (list any);
      inputs = attrs any;
      loader = either function (list any);
      type =
        enum' "options"
          [
            "nixosModules"
            "default"
            "nixosProfiles"
            "evalModules"
            "nixosProfilesOmnibus"
          ]
          "type";
    };

    haumeaLoadExtender = {
      load = structOption "haumea.load" structAttrs.haumeaLoad;
    };

    haumeaLoadExtenderPop = structAttrs.pop // structAttrs.haumeaInitLoadPop;

    haumeaLoadPop = structAttrs.pop // structAttrs.haumeaLoad;
    haumeaInitLoadPop = structAttrs.pop // rec {
      initLoad = struct "haumea.load" structAttrs.haumeaLoad;
      load = structAttrs.haumeaLoadExtender.load;
      #list (either function any);
      setInit = function;
    };
  };
in
structAttrs
