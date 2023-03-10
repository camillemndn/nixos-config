{ config, lib, ... }:

let
  cfg = config.profiles.feeds;
in
with lib;

{
  options.profiles.feeds = {
    enable = mkEnableOption "Feeds";
  };

  config = mkIf cfg.enable {
    services.yarr = {
      enable = true;
      authFile = "/run/secrets/feeds";
    };

    services.vpnVirtualHosts.feeds.port = 7070;

    sops.secrets.feeds = {
      format = "binary";
      owner = "yarr";
      sopsFile = ../../secrets/feeds;
    };
  };
}
