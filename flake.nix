{
  description = "A flake for my personal configurations";

  inputs = {
    ### Nix packages and modules ###
    nixpkgs.url = "nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    nixpkgs-pinned.url = "nixpkgs/1b64fc1287991a9cce717a01c1973ef86cb1af0b";
    home-manager = { url = "home-manager/release-23.11"; inputs.nixpkgs.follows = "nixpkgs"; };
    ################################

    ### Flake utils ###
    colmena.url = "github:zhaofengli/colmena";
    utils = { url = "flake-utils"; inputs.systems.follows = "systems"; };
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
      inputs.flake-utils.follows = "utils";
    };
    #############################

    ### Sofware dependencies ###
    attic = {
      url = "github:zhaofengli/attic";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "utils";
    };

    musnix.url = "github:musnix/musnix";
    nix-index-database = { url = "github:Mic92/nix-index-database"; inputs.nixpkgs.follows = "nixpkgs"; };

    nix-software-center = {
      url = "github:vlinkz/nix-software-center";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "utils";
    };

    simple-nixos-mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "utils";
    };

    spicetify-nix = {
      url = "github:the-argus/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "utils";
    };

    zotero-nix = {
      url = "github:camillemndn/zotero-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ############################
  };

  outputs = inputs: with inputs;

    let lib = nixpkgs.lib.extend (_: prev: import ./lib { lib = prev; inherit utils; }); in

    lib.mergeDefaultSystems (system:

      let
        nixpkgs = lib.patchNixpkgs system inputs.nixpkgs self.patches;

        pkgs = import nixpkgs {
          inherit system;
          overlays = [ self.overlays.${system} ];
          config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
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
        };

        extraHomeModules = lib.attrValues self.homeManagerModules ++ [
          nix-index-database.hmModules.nix-index
          spicetify-nix.homeManagerModule
        ] ++ (import ./profiles/home);

        extraModules = lib.attrValues self.nixosModules ++ [
          home-manager.nixosModules.home-manager
          lanzaboote.nixosModules.lanzaboote
          musnix.nixosModules.musnix
          nix-index-database.nixosModules.nix-index
          nixos-wsl.nixosModules.wsl
          simple-nixos-mailserver.nixosModule
          sops-nix.nixosModules.sops
        ] ++ (import ./profiles);
      in

      {
        packages.${system} = import ./pkgs/top-level { inherit pkgs; };

        overlays.${system} = import ./overlays { inherit lib pkgs self system; };

        patches = {
          clevis = ./overlays/clevis.patch;
          firefoxpwa = ./overlays/firefoxpwa.patch;
          mattermost-desktop = builtins.fetchurl {
            url = "https://github.com/NixOS/nixpkgs/pull/259351/commits/e62dc9e309374cfbadd27bc736d391a606740df8.patch";
            sha256 = "0ikgpbs7zmcm7rg2d62wx24d0byr6vpvv11xxpxpkl5js2309cay";
          };
          quarto = ./overlays/quarto.patch;
          tzupdate = ./overlays/tzupdate.patch;
        };

        machines = import ./machines.nix;

        homeManagerModules = import ./modules/home;

        nixosModules = import ./modules;

        homeConfigurations = import ./configurations/home.nix {
          inherit lib pkgs self extraHomeModules;
        };

        nixosConfigurations = import ./configurations {
          inherit lib pkgs self nixpkgs extraModules extraHomeModules system;
        };

        colmena = import ./colmena.nix { inherit lib pkgs self; };

        devShells.${system}.default = pkgs.mkShell { buildInputs = with pkgs; [ home-manager age colmena nixos-generators nix-update sops ]; };
      });
}
