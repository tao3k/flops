{
  root,
  POP,
  lib,
  yants,
  haumea,
  self,
}:
let
  types = root.types // yants;
  inherit (POP.lib) pop extendPop;
  inherit (root) pops;
  inherit (yants) defun;
  inherit (lib)
    mapAttrs
    mergeToDepth
    foldl
    filter
    deSystemize
    ;
in
{
  recipesExtender = pop {
    defaults = {
      recipes = { };
      initRecipes = { };
    };
    extension = self: super: {
      setInitRecipes = (
        initRecipes: extendPop self (self: super: { inherit initRecipes; })
      );
    };
  };

  argsExtender = pop {
    defaults = {
      args = { };
      argsExtenders = [ ];
    };
    extension = self: super: {
      args = foldl (args: extender: args // extender) { } self.argsExtenders;

      addArgsExtenders = (
        argsExtenders:
        extendPop self (
          self: super: { argsExtenders = super.argsExtenders ++ argsExtenders; }
        )
      );
      addArgsExtender = (argsExtender: self.addArgsExtenders [ argsExtender ]);
    };
  };

  exporter = pop {
    defaults = {
      recipes = { };
      args = { };
      exports = { };
    };
    extension = self: super: {
      setRecipes = (recipes: extendPop self (self: super: { inherit recipes; }));
      setArgs = (args: extendPop self (self: super: { inherit args; }));
      addExporters = (
        exporters:
        extendPop self (self: super: { exporters = super.exporters ++ exporters; })
      );
      addExporter = (exporter: self.addExporters [ exporter ]);
    };
  };

  default = pop {
    supers = [
      self.recipesExtender
      self.argsExtender
      self.exporter
    ];
    defaults = {
      recipesExtenders = [ ];
      exporters = [ ];
    };
    extension = self: super: {
      recipes = foldl (
        attrs: extender: attrs // extender
      ) self.initRecipes self.recipesExtenders;

      addRecipesExtenders = (
        recipesExtenders:
        extendPop self (
          self: super: { recipesExtenders = super.recipesExtenders ++ recipesExtenders; }
        )
      );

      addRecipesExtender = (
        recipesExtender: self.addRecipesExtenders [ recipesExtender ]
      );

      exports = foldl (
        attrs: exporter:
        if self.args != { } then
          mergeToDepth 2 attrs
            ((exporter.setRecipes self.recipes).setArgs self.args).exports
        else
          mergeToDepth 2 attrs (exporter.setRecipes self.recipes).exports
      ) { } self.exporters;
    };
  };
}
