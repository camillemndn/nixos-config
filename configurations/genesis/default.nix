{ pkgs, ... }:

{
  networking = {
    hostName = "genesis";
    networkmanager.enable = true;
  };

  environment.systemPackages = with pkgs; [
    nix-software-center
    amdctl
  ];

  nixpkgs.config.firefox = {
    ffmpegSupport = true;
    enableGnomeExtensions = true;
    enableFirefoxPwa = true;
  };

  profiles = {
    gdm.enable = true;
    gnome.enable = true;
  };

  programs = {
    firefox.enable = true;
    steam.enable = true;
    dconf.enable = true;
  };

  services = {
    logind.killUserProcesses = true;
    power-profiles-daemon.enable = false;
    printing = { enable = true; drivers = [ pkgs.brlaser ]; };
    tailscale.enable = true;
    tlp.enable = true;
    udev.packages = [ pkgs.android-udev-rules ];
  };

  # virtualisation = {
  #   waydroid.enable = true;
  #   lxd.enable = true;
  #   virtualbox.host.enable = true;
  # };
  # users.extraGroups.vboxusers.members = [ "camille" ];

  system.stateVersion = "23.05";
}
