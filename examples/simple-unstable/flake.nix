{
  description = "My NixOs configuration";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.nixos-config.url = "github:jalil-salame/NixOsConfig";
  inputs.home-manager.url = "github:nix-community/home-manager";
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
    # generate with mkpasswd
    # use "pass" as the default password
    # hashedPassword = "$y$j9T$Aw0KN/068RfsefDew3LcI1$OzkJU6juvmUCyEm2n5VYtNlDhSjssOODyAlPn.dG0tA";
    hashedPassword = "";
  in {
    nixosConfigurations.simple = configlib.mkMachine "vm" "x86_64-linux" {
      inherit nixpkgs;
      # system is provided by mkMachine
      timeZone = "Europe/Berlin";
      locale = "en_US.UTF-8";
      # hostName is also provided by mkMachine but we are overriding it
      hostName = "simple";
      users.example = {
        inherit hashedPassword;
        isNormalUser = true;
        extraGroups = ["wheel" "networkmanager" "video"];
        isGUIUser = true;
      };
      extraModules = [nixos-generators.nixosModules.all-formats];
      extraHomeModules = [];
    };
  };
}
