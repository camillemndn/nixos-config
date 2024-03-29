{ pkgs, self, ... }:

{
  imports = [
    (import "${self.inputs.mobile-nixos}/lib/configuration.nix" { device = "pine64-pinephone"; })
    "${self.inputs.mobile-nixos}/examples/phosh/phosh.nix"
  ];

  networking.hostName = "pinkfloyd";

  # Use Network Manager
  networking.wireless.enable = false;
  networking.networkmanager.enable = true;

  # Use PulseAudio
  hardware.pulseaudio.enable = true;

  # Enable Bluetooth
  hardware.bluetooth.enable = true;

  # Bluetooth audio
  hardware.pulseaudio.package = pkgs.pulseaudioFull;

  # Enable power management options
  powerManagement.enable = true;

  # It's recommended to keep enabled on these constrained devices
  zramSwap.enable = true;

  # Auto-login for phosh
  services.xserver.desktopManager.phosh.user = "camille";
  services.openssh.enable = true;

  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [ vlc ];

  # User configuration
  users.users."camille".extraGroups = [ "dialout" "feedbackd" "video" ];

  system.stateVersion = "23.05";
}
