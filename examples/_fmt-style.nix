{ lib }:
let
  inherit (lib)
    dashboard
    kPop
    row
    link
  ;
in
[
  ((((((((((((lib.dashboard.new { title = "test"; }).addTemplate (
    kPop { test1 = true; }
  )).addTemplates
    ([
      (kPop { test2 = true; })
      (kPop { test3 = true; })
    ])
  ).addRow
    (
      row.new {
        title = "1";
        height = "250px";
      }
    )
  ).addRow
    (
      row.new {
        title = "2";
        height = "250px";
      }
    )
  ).addRows
    [
      (row.new {
        title = "1";
        height = "250px";
      })
      (row.new {
        title = "2";
        height = "250px";
      })
    ]
  ).addAnnotation
    "foo"
  ).addAnnotation
    "bar"
  ).addAnnotations
    [
      "foo2"
      "bar2"
    ]
  ).addLink
    "foolinks"
  ).addLink
    "barlinks"
  ).addLinks
    [
      (link.dashboards {
        title = "foo";
        tags = [
          "foo"
          "bar"
        ];
      })
      (link.dashboards {
        title = "bar";
        tags = [
          "foo"
          "bar"
        ];
      })
    ]
  ).__unpop__

  ((((((dashboard.new { title = "test2"; }).addPanel {
    panel = row.new { title = "id0"; };
    gridPos = {
      x = 14;
      y = 42;
      w = 33;
      h = 26;
    };
  }).addPanel
    {
      panel = row.new { title = "id1"; };
      gridPos = {
        x = 24;
        y = 52;
        w = 43;
        h = 36;
      };
    }
  ).addPanel
    {
      panel = row.new { title = "id2"; };
      gridPos = {
        x = 34;
        y = 62;
        w = 53;
        h = 36;
      };
    }
  ).addPanel
    {
      panel = row.new { title = "id5"; };
      gridPos = {
        x = 44;
        y = 72;
        w = 63;
        h = 46;
      };
    }
  ).addPanels
    [
      (lib.kxPop (row.new { title = "id5"; }) {
        x = 41;
        y = 71;
        w = 61;
        h = 41;
      })
    ]
  ).__unpop__

  (((((dashboard.new { title = "test2"; }).addPanel {
    panel = row.new { title = "id0"; };
    gridPos = {
      x = 14;
      y = 42;
      w = 33;
      h = 26;
    };
  }).addPanel
    {
      panel = row.new { title = "id1"; };
      gridPos = {
        x = 24;
        y = 52;
        w = 43;
        h = 36;
      };
    }
  ).addPanel
    {
      panel = row.new { title = "id2"; };
      gridPos = {
        x = 34;
        y = 62;
        w = 53;
        h = 36;
      };
    }
  ).addPanel
    {
      panel = row.new { title = "id5"; };
      gridPos = {
        x = 44;
        y = 72;
        w = 63;
        h = 46;
      };
    }
  ).__unpop__

  (((dashboard.new { title = "subId"; }).addPanels [
    (lib.kxPop
      (row.new {
        title = "id0";
        height = "250px";
      })
      {
        panels = [
          (kPop { foo = "id1"; })
          (kPop { bar = "id2"; })
        ];
      }
    )
    (row.new {
      title = "id3";
      height = "250px";
    })
    (row.new {
      title = "id4";
      height = "250px";
    })
    (kPop { title = "id5"; })
    (kPop { title = "id6"; })
    (kPop { title = "id7"; })
    (kPop { title = "id8"; })
    (lib.kxPop
      (row.new {
        title = "id9";
        height = "250px";
      })
      {
        panels = [
          (kPop { foo = "id10"; })
          (kPop { bar = "id11"; })
        ];
      }
    )
    (kPop { title = "id12"; })
    (kPop { title = "id13"; })
    (kPop { title = "id14"; })
  ]).addPanels
    [
      (lib.kxPop (row.new { title = "id15"; }) {
        panels = [
          (kPop { foo = "id16"; })
          (kPop { bar = "id17"; })
        ];
      })
      (row.new { title = "id18"; })
      (row.new { title = "id19"; })
      (kPop { title = "id20"; })
      (kPop { title = "id21"; })
      (kPop { title = "id22"; })
      (kPop { title = "id23"; })
    ]
  ).__unpop__

  (((((dashboard.new { title = "test3"; }).addPanel {
    panel = kPop { foo = "bar"; };
    gridPos = {
      x = 14;
      y = 42;
      w = 33;
      h = 26;
    };
  }).addPanel
    {
      panel = kPop { foo = "bar"; };
      gridPos = {
        x = 24;
        y = 52;
        w = 43;
        h = 36;
      };
    }
  ).addPanel
    {
      panel = kPop { foo = "bar"; };
      gridPos = {
        x = 34;
        y = 62;
        w = 53;
        h = 36;
      };
    }
  ).addPanel
    {
      panel = kPop { foo = "bar"; };
      gridPos = {
        x = 44;
        y = 72;
        w = 63;
        h = 46;
      };
    }
  ).__unpop__
]
