{
  # Change back once gitoxide 0.30.0 lands
  # inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.home-manager.url = "github:nix-community/home-manager";
  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware/master";

  inputs.nvim-config.url = "github:jalil-salame/nvim-config";

  # Deduplicate inputs
  inputs.nvim-config.inputs.nixpkgs.follows = "nixpkgs";
  inputs.nvim-config.inputs.flake-utils.follows = "flake-utils";
  inputs.nvim-config.inputs.home-manager.follows = "home-manager";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  outputs = {
    self,
    nixpkgs,
    home-manager,
    flake-utils,
    nvim-config,
    nixos-hardware,
  }: let
    lib = (import ./lib.nix) // {inherit machines mkNixOSConfig mkMachine;};
    machines.gemini.hardware = [
      (import ./machines/gemini)
      nixos-hardware.nixosModules.common-pc
      nixos-hardware.nixosModules.common-pc-hdd
      nixos-hardware.nixosModules.common-pc-ssd
      nixos-hardware.nixosModules.common-cpu-amd
      nixos-hardware.nixosModules.common-gpu-amd
    ];
    machines.capricorn.hardware = [
      (import ./machines/capricorn)
      nixos-hardware.nixosModules.common-pc-laptop
      nixos-hardware.nixosModules.common-pc-laptop-hdd
      nixos-hardware.nixosModules.common-pc-laptop-ssd
      nixos-hardware.nixosModules.common-cpu-intel
    ];
    mkMachine = hostname: system: opts:
      mkNixOSConfig ({
          inherit (machines.${hostname}) hardware;
          inherit system;
        }
        // opts);
    mkNixOSConfig = {
      nixpkgs,
      system,
      hardware ? [],
      users,
      timeZone,
      locale,
      unfree ? [],
      extraModules ? [],
      extraHomeModules ? [],
    }: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [nvim-config.overlays.default];
        config.allowUnfreePredicate = pkg:
          builtins.elem (lib.getName pkg) (unfree
            ++ [
              "mpv-thumbfast"
              "steam"
              "steam-run"
              "steam-original"
              "steam-runtime"
              "vscode"
            ]);
      };
      inherit (pkgs) lib;
      nixpkgs-flake = nixpkgs;
      # inherit (packages) nixpkgs-flake pkgs nixosSystem;
      nvim-modules = {inherit (nvim-config.nixosModules) nixneovim nvim-config;};
      # Pass args needed for Home-Manager
      userArgs = username: {
        isGUIUser ? false,
        accounts ? {},
        gitconfig ? {},
        ...
      }:
        import ./home {inherit isGUIUser username accounts gitconfig extraHomeModules;};
      home-manager-users = builtins.mapAttrs userArgs users;
    in
      nixpkgs.lib.nixosSystem {
        specialArgs = {
          guiEnvironment = true;
          installSteam = false;
        };
        inherit system pkgs;
        modules =
          hardware
          ++ extraModules
          ++ [
            (import ./common {
              inherit timeZone locale users nixpkgs-flake;
            })
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users = home-manager-users;
              home-manager.extraSpecialArgs = {inherit nvim-modules;};
            }
          ];
      };
  in
    {
      inherit lib;
      nixosConfigurations.example = mkNixOSConfig {
        inherit nixpkgs;
        system = "x86_64-linux";
        timeZone = "Europe/Berlin";
        locale = "en_US.UTF-8";
        # gemini's hardware includes rocm support (+3 GiB)
        inherit (machines.capricorn) hardware;
        users = {
          user1 = {
            hashedPassword = ""; # generate with mkpasswd
            isNormalUser = true;
            extraGroups = ["wheel" "networkmanager"];
            isGUIUser = true;
            gitconfig = {}; # See home-manager module
            accounts = {}; # Use mkGmailAccount or mkEmailAccount
          };
          user2 = {
            hashedPassword = ""; # generate with mkpasswd
            extraGroups = ["networkmanager"];
            isNormalUser = true;
          };
        };
      };
    }
    // flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {inherit system;};
      in {
        formatter = pkgs.alejandra;
      }
    );
}
