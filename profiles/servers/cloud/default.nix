{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.cloud;
in
with lib;

{
  options.profiles.cloud = {
    enable = mkEnableOption "Activate my Nextcloud instance";
  };

  config = mkIf cfg.enable {
    services.nextcloud = {
      enable = true;
      package = pkgs.nextcloud27;
      hostName = "cloud.mondon.xyz";

      autoUpdateApps.enable = true;
      caching.redis = true;
      database.createLocally = true;
      enableBrokenCiphersForSSE = false;
      https = true;
      maxUploadSize = "4G";
      phpOptions."opcache.interned_strings_buffer" = "23";

      config = {
        adminuser = "Camille";
        adminpassFile = "/run/secrets/nextcloud";
        dbtype = "mysql";
        defaultPhoneRegion = "FR";
        overwriteProtocol = "https";
      };
    };

    services.redis.servers.nextcloud = {
      enable = true;
      user = "nextcloud";
      port = 0;
    };

    sops.secrets.nextcloud = {
      format = "binary";
      sopsFile = ./adminpass;
      owner = "nextcloud";
      group = "nextcloud";
    };
  };
}
