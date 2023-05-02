{
  lib,
  inputs,
}: let
  inherit (inputs) POP dmerge;
  inherit (lib.configs) haumea;
  nixosModules =
    ((((haumea.setInit {
            src = ./__fixture;
            inputs = {
              POP = inputs.POP;
            };
            transformer = with inputs.haumea.lib.transformers; [
              liftDefault
            ];
          })
          .addInputs {
            lib = inputs.nixlib.lib;
          })
        .addTransformer (with inputs.haumea.lib.transformers; [
          (hoistLists "_imports" "imports")
          (hoistAttrs "_options" "options")
        ]))
      .addMerge (
        final:
          with dmerge;
          # merge final {services.openssh.merge = "merge";}
            merge final {services.openssh.customList2 = append ["b" "c"];}
      ))
    .addMerge (
      final:
        with dmerge;
          merge final {services.openssh.customList = append ["merge"];}
    );
in
  nixosModules.outputsForTarget "nixosModules"
