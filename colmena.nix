{ lib, pkgs, self }:

{
  meta = {
    nixpkgs = pkgs;
    nodeNixpkgs = builtins.mapAttrs (_: v: v.pkgs) self.nixosConfigurations;
    nodeSpecialArgs = builtins.mapAttrs (_: v: v._module.specialArgs) self.nixosConfigurations;
    specialArgs.lib = lib;
  };
} // builtins.mapAttrs
  (n: v: {
    imports = v._module.args.modules ++ v._module.args.extraModules;
    #nixpkgs.config = lib.mkForce { };
    deployment = self.machines.${n}.deployment // { buildOnTarget = lib.mkDefault true; };
  })
  self.nixosConfigurations
