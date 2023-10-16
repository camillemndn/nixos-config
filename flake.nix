{
  description = "A flake for my personal configurations";

  inputs = {
    ### Nix packages and modules ###
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-pinned.url = "nixpkgs/fdd898f8f79e8d2f99ed2ab6b3751811ef683242";
    home-manager = { url = "home-manager"; inputs.nixpkgs.follows = "nixpkgs"; };
    ################################

    ### Flake utils ###
    colmena.url = "github:zhaofengli/colmena";
    flake-utils = { url = "flake-utils"; inputs.systems.follows = "systems"; };
    utils = { url = "github:gytis-ivaskevicius/flake-utils-plus"; inputs.flake-utils.follows = "flake-utils"; };
    systems = { url = "https://raw.githubusercontent.com/camillemndn/nixos-config/main/systems.nix"; flake = false; };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ###################

    ### Hardware dependencies ###
    lanzaboote.url = "github:nix-community/lanzaboote/45d04a45d3dfcdee5246f7c0dfed056313de2a61";
    mobile-nixos = { url = "github:camillemndn/mobile-nixos"; flake = false; };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    #############################

    ### Sofware dependencies ###
    attic = {
      url = "github:zhaofengli/attic";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    hyprland = { url = "github:hyprwm/Hyprland?ref=v0.30.0"; inputs.nixpkgs.follows = "nixpkgs"; };
    hyprland-contrib = { url = "github:hyprwm/contrib"; inputs.nixpkgs.follows = "nixpkgs"; };

    musnix.url = "github:musnix/musnix";

    nix-index-database = { url = "github:Mic92/nix-index-database"; inputs.nixpkgs.follows = "nixpkgs"; };

    nix-software-center = {
      url = "github:vlinkz/nix-software-center";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "flake-utils";
    };

    simple-nixos-mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "flake-utils";
    };

    spicetify-nix = {
      url = "github:the-argus/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    ############################
  };


  outputs = inputs: with inputs;
    let lib = nixpkgs.lib.extend (_: prev: import ./lib { lib = prev; inherit utils; }); in
    utils.lib.mkFlake {
      inherit self inputs;

      # Channel definitions.
      # Channels are automatically generated from nixpkgs inputs
      # e.g the inputs which contain `legacyPackages` attribute are used.
      channelsConfig.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
        "corefonts"
        "harmony-assistant"
        "mac"
        "nvidia-settings"
        "nvidia-x11"
        "reaper"
        "spotify"
        "steam"
        "steam-original"
        "steam-run"
        "unrar"
        "zoom"
      ];

      channels.nixpkgs = {
        patches = lib.attrValues self.patches;
        overlaysBuilder = channels: [
          (final: prev: lib.updateManyAttrs [
            self.packages.${system}
            {
              inherit lib;
              pinned = import nixpkgs-pinned { inherit system; inherit (pkgs) config; };

              # Adds some packages from other flakes
              spicetify-nix = spicetify-nix.packages.${system}.default;
              inherit (hyperland.packages.${system}) xdg-desktop-portal-hyprland;
              inherit (hyprland-contrib.packages.${system}) grimblast;
              inherit (nix-software-center.packages.${system}) nix-software-center;
              inherit (attic.packages.${system}) attic;
            }
          ])
        ];
      };

      # Modules shared between all hosts
      hostDefaults.modules = lib.attrValues self.nixosModules ++ [
        home-manager.nixosModules.home-manager
        hyprland.nixosModules.default
        lanzaboote.nixosModules.lanzaboote
        musnix.nixosModules.musnix
        nix-index-database.nixosModules.nix-index
        nixos-wsl.nixosModules.wsl
        simple-nixos-mailserver.nixosModule
        sops-nix.nixosModules.sops
      ] ++ (import ./profiles);

      ### Hosts ###

      # Machine using default channel (nixpkgs)
      hosts = import ./hosts.nix;

      extraHomeModules = lib.attrValues self.homeManagerModules ++ [
        hyprland.homeManagerModules.default
        nix-index-database.hmModules.nix-index
        spicetify-nix.homeManagerModule
      ] ++ (import ./profiles/home);

      outputsBuilder = channels: with channels.nixpkgs; {

        packages = import ./pkgs/top-level {
          inherit pkgs;
        };

        overlays = import ./overlays { inherit lib pkgs inputs system; };

        devShells.default = pkgs.mkShell { buildInputs = with pkgs; [ age colmena nixos-generators sops ]; };
      };

      patches = {
        firefoxpwa = ./overlays/firefoxpwa.patch;
        jellyseerr = builtins.fetchurl {
          url = "https://github.com/NixOS/nixpkgs/pull/259076.patch";
          sha256 = "1awbxzksh2p482fw5lq9lzn92s8n224is9krz8irqc1nbd5fm5jf";
        };
        jitsi-meet = builtins.fetchurl {
          url = "https://github.com/NixOS/nixpkgs/pull/227588.patch";
          sha256 = "0zh6hxb2m7wg45ji8k34g1pvg96235qmfnjkrya6scamjfi1j19l";
        };
        mattermost-desktop = builtins.fetchurl {
          url = "https://github.com/NixOS/nixpkgs/pull/259351.patch";
          sha256 = "0ikgpbs7zmcm7rg2d62wx24d0byr6vpvv11xxpxpkl5js2309cay";
        };
      };

      machines = import ./machines.nix;

      homeManagerModules = import ./modules/home;

      nixosModules = import ./modules;

      # colmena = import ./colmena.nix { inherit lib pkgs self inputs nixpkgs; };
    };
}
