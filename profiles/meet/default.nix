{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.meet;
in
with lib;

{
  options.profiles.meet = {
    enable = mkEnableOption "Jitsi";
    hostName = mkOption {
      type = types.str;
      default = "meet.kms";
    };
  };

  config = mkIf cfg.enable {
    services.jitsi-meet = {
      enable = true;
      hostName = cfg.hostName;
      nginx.enable = true;
      prosody.enable = true;
      videobridge.enable = true;
      jicofo.enable = true;
      excalidraw.enable = true;
      secureDomain.enable = true;
    };

    services.jitsi-videobridge = {
      openFirewall = true;
      nat = {
        publicAddress = "78.194.168.230";
        localAddress = "192.168.1.137";
      };
    };

    # services.nginx.virtualHosts."${cfg.hostName}" = {
    #   enableACME = false;
    #   forceSSL = false;
    # };

    services.prosody.extraConfig = ''
      log = {
        warn = "*syslog";
      }
    '';

    nixpkgs.overlays = [
      (final: prev: {
        jicofo = prev.jicofo.overrideAttrs (old: {
          version = "1.0-996";
          src = pkgs.fetchurl {
            url = "https://download.jitsi.org/stable/jicofo_1.0-996-1_all.deb";
            sha256 = "sha256-X0dDBuLQQGG8gicbVZW+KkmGNX4DlMbEIzM/dzjPglE=";
          };
        });
        jitsi-videobridge = prev.jitsi-videobridge.overrideAttrs (old: {
          version = "2.2-79-gf6426ea0";
          src = pkgs.fetchurl {
            url = "https://download.jitsi.org/stable/jitsi-videobridge2_2.2-79-gf6426ea0-1_all.deb";
            sha256 = "sha256-WJI9JCRtacuVPugv3s/NIwLvDX/bjnia/hDidqeuY04=";
          };
        });
        jitsi-meet = prev.jitsi-meet.overrideAttrs (old: {
          version = "1.0.7212";
          src = pkgs.fetchurl {
            url = "http://download.jitsi.org/jitsi-meet/src/jitsi-meet-1.0.7212.tar.bz2";
            sha256 = "sha256-LkcSSRRxB/x8heKFq9yfdf9yrG3wnu42kI8jWcN2LuQ=";
          };
        });
        jitsi-meet-prosody = prev.jitsi-meet-prosody.overrideAttrs (old: {
          version = "1.0.6991";
          src = pkgs.fetchurl {
            url = "http://download.jitsi.org/stable/jitsi-meet-prosody_1.0.6991-1_all.deb";
            sha256 = "sha256-kgcbYpIM1lFmPrNPo4taD3EcL9LQc2Xxh3xEkDXCKhY=";
          };
        });
      })
    ];
  };
}

