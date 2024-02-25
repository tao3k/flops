{
  description = "Flops";

  inputs.omnibus.url = "github:gtrunsec/omnibus";
  inputs.call-flake.url = "github:divnix/call-flake";
  inputs.namaka.follows = "";

  outputs =
    { ... }@inputs:
    let
      inherit (inputs.omnibus.flake.inputs) std nixpkgs;
      main = inputs.call-flake ../.;
    in
    std.growOn
      {
        inputs = inputs // {
          inherit std nixpkgs;
        };
        cellsFrom = ./cells;
        cellBlocks = with std.blockTypes; [
          # Development Environments
          (nixago "nixago")
          (functions "pops")
          (devshells "shells")
          (data "configs")
        ];
      }
      {
        devShells = std.harvest inputs.self [
          [
            "repo"
            "shells"
          ]
        ];
      }
      {
        checks = inputs.namaka.lib.load {
          src = ../tests;
          inputs = main.lib // {
            inherit (main) inputs;
            lib = main.inputs.nixlib.lib // main.lib;
          };
        };
      };
}
