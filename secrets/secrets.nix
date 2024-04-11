let
  liv-lila = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGXi00z/rxVrWLKgYr+tWIsbHsSQO75hUMSTThNm5wUw liv@lila";
  liv-quack = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDIDaB1pwad4/Qse/ywxtNB9WpRPjyTL/ugJ61Qk3XZS liv@quack";
  users = [ liv-lila liv-quack ];

  quack = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDIDaB1pwad4/Qse/ywxtNB9WpRPjyTL/ugJ61Qk3XZS liv@quack";
  systems = [ quack ];
in
{
  "quack.age".publicKeys = [ liv-lila liv-quack quack ];
  "matrix-synapse.age".publicKeys = [ liv-lila liv-quack quack ];
  "secrets.age".publicKeys = users ++ systems;
}
