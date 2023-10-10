{
  POP,
  haumea,
  yants,
  super,
  lib,
  dmerge,
  self,
}:
let
  inherit (POP.lib) pop extendPop;
  inherit (yants) defun;
  inherit (super) nixosModules;

  trace = x: l.trace x x;
  types = yants // super.types;
  l = lib // builtins;

  loadExtender = pop {
    defaults = {
      initLoad = {
        src = ./.;
        loader = haumea.lib.loaders.default;
        inputs = { };
        transformer = [ ];
        type = "default";
      };
      load = { };
    };
    extension = self: super: {
      setInit =
        defun
          (
            with types; [
              (attrs any)
              haumeaInitLoadPop
            ]
          )
          (
            initLoad:
            extendPop self (self: super: { initLoad = super.initLoad // initLoad; })
          );
    };
  };

  exporter = pop {
    defaults = {
      exports = { };
      load = { };
    };
    supers = [ ];
    extension = self: super: {
      setLoad =
        defun
          (
            with types; [
              haumeaLoadPop
              haumeaExporterPop
            ]
          )
          (
            load:
            extendPop self (
              self: super: {
                load = {
                  inherit (load) loader transformer type;
                  src =
                    if l.isString load.src then l.unsafeDiscardStringContext load.src else load.src;
                  inputs = l.removeAttrs load.inputs [ "self" ];
                };
              }
            )
          );

      setLayouts = (layouts: extendPop self (self: super: { inherit layouts; }));

      setOutputs =
        defun
          (
            with types; [
              (attrs any)
              haumeaExporterPop
            ]
          )
          (outputs: extendPop self (self: super: { inherit outputs; }));
    };
  };

  default = pop {
    supers = [
      loadExtender
      exporter
    ];
    defaults = {
      loadExtenders = [ ];
      exporters = [ ];
    };
    extension = self: super: {
      # -- exports --
      exports =
        let
          generalExporters =
            l.foldl
              (
                acc: extender:
                let
                  ex' =
                    if extender ? setOutputs then
                      ((extender.setOutputs self.outputs).setLayouts self.layouts).exports
                    else
                      extender.exports
                  ;
                in
                acc // ex'
              )
              { }
              self.exporters;
        in
        generalExporters;

      # -- exportersExtener --
      addExporter = exporter: self.addExporters [ exporter ];
      addExporters =
        exporters:
        extendPop self (self: super: { exporters = super.exporters ++ exporters; });

      # -- load --
      load =
        l.foldl
          (
            acc: extender:
            let
              ext' =
                if (extender ? setInit) then
                  (extender.setInit self.initLoad).load
                else
                  extender.load
              ;
            in
            l.recursiveMerge ([
              # NOTE: put the ext' first so that the initLoad is the last to be merged
              acc
              ext'
            ])
          )
          self.initLoad
          self.loadExtenders;

      # -- loadExtenders --
      addLoadExtender =
        defun
          (
            with types; [
              (either haumeaInitLoadPop (attrs any))
              haumeaDefaultPop
            ]
          )
          (loadExtender: self.addLoadExtenders [ loadExtender ]);

      addLoadExtenders =
        defun
          (
            with types; [
              (either (list haumeaInitLoadPop) (list (attrs any)))
              haumeaDefaultPop
            ]
          )
          (
            loadExtenders:
            extendPop self (
              self: super: { loadExtenders = super.loadExtenders ++ loadExtenders; }
            )
          );

      # -- outputs --
      # laziest way to get the outputs
      # default is to merge the outputs with dmerege
      outputs =
        defun
          (
            with types; [
              (eitherN [
                function
                (attrs any)
                (list (attrs any))
              ])
              (attrs any)
            ]
          )
          (
            x:
            if self.layouts ? __extenders then
              self.layouts.__extenders x
            else if l.isFunction x then
              x self.layouts.default
            else if x != { } then
              dmerge.merge self.layouts.default x
            else
              self.layouts.default
          );

      layouts =
        (
          let
            cfg = (exporter.setLoad self.load).load;
            haumeaOutputs =
              if
                (l.elem cfg.type [
                  "nixosModules"
                  "nixosProfiles"
                  "evalModules"
                ])
              then
                nixosModules { inherit cfg; }
              else
                { default = haumea.lib.load (l.removeAttrs cfg [ "type" ]); }
            ;
          in
          haumeaOutputs // (l.removeAttrs self.exports [ "default" ])
        );
    };
  };
in
{
  inherit default loadExtender exporter;
}