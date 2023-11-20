{
  description = "My NixOs configuration";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
  inputs.nixos-config.url = "github:jalil-salame/NixOsConfig";
  inputs.home-manager.url = "github:nix-community/home-manager/release-23.05";
  inputs.nixos-generators.url = "github:nix-community/nixos-generators";

  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";
  inputs.nixos-config.inputs.nixpkgs.follows = "nixpkgs";
  inputs.nixos-config.inputs.home-manager.follows = "home-manager";
  inputs.nixos-generators.inputs.nixpkgs.follows = "nixpkgs";

  outputs = {
    nixpkgs,
    nixos-config,
    nixos-generators,
    ... # ignoring home-manager
  }: let
    configlib = nixos-config.lib;
  in {
    nixosConfigurations.simple = configlib.mkMachine "vm" "x86_64-linux" {
      inherit nixpkgs;
      unstable = false;
      # system is provided by mkMachine
      timeZone = "Europe/Berlin";
      locale = "en_US.UTF-8";
      # hostName is also provided by mkMachine but we are overriding it
      hostName = "simple";
      users.example = {
        hashedPassword = ""; # generate with mkpasswd
        isNormalUser = true;
        extraGroups = ["wheel" "networkmanager" "video"];
        # isGUIUser = true;
      };
      extraModules = [nixos-generators.nixosModules.all-formats];
      extraHomeModules = [];
    };
  };
}
