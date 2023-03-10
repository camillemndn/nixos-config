{ config, lib, ... }:

let
  cfg = config.profiles.office;
in
with lib;

{
  options.profiles.office = {
    enable = mkEnableOption "Only Office";
    hostName = mkOption {
      type = types.str;
      default = "office.kms";
    };
  };

  config = mkIf cfg.enable {
    services.onlyoffice = {
      enable = true;
      enableExampleServer = true;
      examplePort = 8001;
      # jwtSecretFile = "/run/secrets/onlyoffice";
    };

    services.vpnVirtualHosts.office.port = 8000;
    # services.vpnVirtualHosts."edit.office".port = 8001;
    # sops.secrets.onlyoffice = {};
  };
}
