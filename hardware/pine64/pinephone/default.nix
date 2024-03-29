{ lib, ... }:

{
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/55618c74-86d8-47e8-952a-5809ec5fa99e";
      fsType = "ext4";
    };
  };

  nix.settings.max-jobs = lib.mkDefault 2;
}
