{ inputs }:
let
  l = inputs.nixlib.lib // builtins;
  inherit (inputs.POP.lib) pop extendPop kxPop;
  A = pop {
    defaults = {
      a = 5;
      b = 2;
      e = {
        x = 1;
        y = 2;
      };
    };
    extension = self: super: {
      a = super.a + 1;
      c = 3;
    };
  };
  B = pop {
    defaults = {
      fExtenders = [ ];
    };
    supers = [ A ];
    extension = self: super: {
      d = super.a + super.c;
      inputs = l.fold (acc: ext: acc // ext) self.e self.fExtenders;
      addf =
        fExtenders:
        extendPop self (self: super: { fExtenders = super.fExtenders ++ fExtenders; });
    };
  };
  C = B.addf [ (extendPop A (self: super: { g = self.a; })) ];
in
{
  inherit A B C;

  functorOrPop =
    (name: {
      __functor = self: selectors: self // selectors;
      inherit name;
      type = "__functor";
    })
      "functor";
}
