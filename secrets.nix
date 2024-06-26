let
  camille = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINg9kUL5kFcPOWmGy/7kJZMlG2+Ls79XiWgvO8p+OQ3f";
  admins = [ camille ];
  zeppelin = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDNKOAMN3AxfW6HKrom5s6D4Yy9WYEAK2FuOQYWLuFm3";
in
{
  "profiles/ci/buildbot-nix-worker-password.age".publicKeys = admins ++ [ zeppelin ];
  "profiles/ci/buildbot-nix-workers.age".publicKeys = admins ++ [ zeppelin ];
  "profiles/ci/github-app-secret.age".publicKeys = admins ++ [ zeppelin ];
  "profiles/ci/github-oauth-secret.age".publicKeys = admins ++ [ zeppelin ];
  "profiles/ci/github-webhook-secret.age".publicKeys = admins ++ [ zeppelin ];
}
