{ lib, utils, ... }:

with lib;

rec {
  # Strings

  hasSuffixIn = l: x: elem true (map (s: hasSuffix s x) l);

  # Attribute sets
  recursiveUpdateManyAttrs = foldl recursiveUpdate { };

  updateManyAttrs = foldl (x: y: x // y) { };

  genAttrs' = names: f: listToAttrs (map f names);

  flattenAttrs = f: concatMapAttrs (n: v: mapAttrs' (v: val: nameValuePair (f n v) val) v);

  # Flake utils

  mergeDefaultSystems = x: recursiveUpdateManyAttrs (map x utils.lib.defaultSystems);

  platformMatches = x: sys: filterAttrs (_: pkg: elem sys pkg.meta.platforms) x;

  patchNixpkgs = system: nixpkgs: patches: (import nixpkgs { inherit system; }).applyPatches {
    name = "nixpkgs-patched";
    src = nixpkgs;
    patches = attrValues patches;
  };

  nixosSystem' =
    args@{ configuration
    , hardware
    , users
    , ...
    }: lib.nixosSystem (lib.recursiveUpdate
      {
        inherit lib;
        specialArgs = { inherit self nixpkgs; };
        baseModules = import "${nixpkgs}/nixos/modules/module-list.nix";
        modules = extraModules ++ [
          (import ./${configuration})
          (import ../hardware/${hardware})
          {
            #imports = [ self.inputs.nixpkgs.nixosModules.readOnlyPkgs ];
            nixpkgs = { inherit pkgs; };

            home-manager = {
              useGlobalPkgs = true;
              sharedModules = extraHomeModules;
              users = lib.genAttrs users (user: lib.importIfExists ./${configuration}/home/${user}.nix);
            };
          }
        ];
      }
      (builtins.removeAttrs args [ "configuration" "hardware" "users" ]));

  mapSystemsFromMachines = defaultUser: lib.mapAttrs (configuration: args: nixosSystem' {
    inherit configuration;
    inherit (args) hardware;
    users = args.users or [ defaultUser ];
  });

  # Paths

  importIfExists = p: if (builtins.pathExists p) then import p else _: { };
}
