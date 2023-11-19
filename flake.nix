{
  # inputs.nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable-small";
  inputs.nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.nvim-config-unstable.url = "github:jalil-salame/nvim-config";
  inputs.home-manager-unstable.url = "github:nix-community/home-manager";

  inputs.nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-23.05";
  inputs.nvim-config-stable.url = "github:jalil-salame/nvim-config";
  inputs.home-manager-stable.url = "github:nix-community/home-manager";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  inputs.nixos-generators.url = "github:nix-community/nixos-generators";

  # Deduplicate inputs
  inputs.nvim-config-stable.inputs.nixpkgs.follows = "nixpkgs-stable";
  inputs.nvim-config-stable.inputs.flake-utils.follows = "flake-utils";
  inputs.nvim-config-stable.inputs.home-manager.follows = "home-manager-stable";
  inputs.nvim-config-unstable.inputs.nixpkgs.follows = "nixpkgs-unstable";
  inputs.nvim-config-unstable.inputs.flake-utils.follows = "flake-utils";
  inputs.nvim-config-unstable.inputs.home-manager.follows = "home-manager-unstable";

  inputs.home-manager-stable.inputs.nixpkgs.follows = "nixpkgs-stable";
  inputs.home-manager-unstable.inputs.nixpkgs.follows = "nixpkgs-unstable";

  inputs.nixos-generators.inputs.nixpkgs.follows = "nixpkgs-unstable";

  outputs = {
    self,
    nixpkgs-unstable,
    nixpkgs-stable,
    home-manager-unstable,
    home-manager-stable,
    flake-utils,
    nvim-config-unstable,
    nvim-config-stable,
    nixos-hardware,
    nixos-generators,
  }: let
    lib = (import ./lib.nix) // {inherit machines mkNixOSConfig mkMachine;};
    # Machines' hardware configuration
    machines = {
      gemini.tempInfo.hwmon-path = "/sys/class/hwmon/hwmon2/temp2_input"; # Tdie
      gemini.hardware = [
        (import ./machines/gemini)
        nixos-hardware.nixosModules.common-pc
        nixos-hardware.nixosModules.common-pc-hdd
        nixos-hardware.nixosModules.common-pc-ssd
        nixos-hardware.nixosModules.common-cpu-amd
        nixos-hardware.nixosModules.common-gpu-amd
      ];

      capricorn.tempInfo.hwmon-path = "/sys/class/hwmon/hwmon2/temp1_input";
      capricorn.hardware = [
        (import ./machines/capricorn)
        nixos-hardware.nixosModules.common-pc-laptop
        nixos-hardware.nixosModules.common-pc-laptop-hdd
        nixos-hardware.nixosModules.common-pc-laptop-ssd
        nixos-hardware.nixosModules.common-cpu-intel
      ];
      vm.hardware = [
        (import ./machines/vm)
      ];
    };
    # Convenience function that creates a NixOS Configuration using a specific hardware module
    #
    # See macchines
    mkMachine = hostName: system: opts:
      mkNixOSConfig (
        let
          machine = machines.${hostName};
          hardware = machine.hardware;
        in
          opts
          // {
            inherit system;
            inherit hostName;
            extraModules = hardware ++ opts.extraModules;
          }
          // (
            if builtins.hasAttr "tempInfo" machine
            then {inherit (machine) tempInfo;}
            else {}
          )
      );
    # Convenience function that creates a NixOS Configuration
    mkNixOSConfig = {nixpkgs, ...} @ params: nixpkgs.lib.nixosSystem (mkConfig params);
    # Backbone of this module that creates a NixOS Configuration attrset
    mkConfig = {
      # The nixpkgs input to use (should be nixos-unstable)
      nixpkgs,
      # whether we are using nixpkgs-unstable
      unstable ? true,
      # System hardware; i.e. "x86_64-linux" or "aarch64-linux"
      system,
      # The users to setup, see the example config
      users,
      # The system's time zone; i.e. "Europe/Berlin"
      timeZone,
      # The system's locale; i.e. "en_US.UTF-8"
      locale,
      # The system's hostName
      hostName ? null,
      # Temperature sensor to monitor
      tempInfo ? null,
      # What unfree packages to allow
      unfree ? [],
      # Extra NixOs modules to enable
      extraModules ? [],
      # Extra home-manager modules to enable
      extraHomeModules ? [],
    }: let
      nvim-config =
        if unstable
        then nvim-config-unstable
        else nvim-config-stable;
      home-manager =
        if unstable
        then home-manager-unstable
        else home-manager-stable;
      nvim-modules =
        if unstable
        then {
          inherit (nvim-config.nixosModules) nvim-config nixneovim;
        }
        else {
          inherit (nvim-config.nixosModules) nvim-config;
          nixneovim = nvim-config.nixosModules.nixneovim-23-05;
        };
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
      # Pass args needed for Home-Manager
      userArgs = username: {
        isGUIUser ? false,
        accounts ? {},
        gitconfig ? {},
        startup ? {
          once = [];
          always = [];
        },
        displays ? {},
        ...
      }:
        import ./home {inherit isGUIUser username accounts gitconfig extraHomeModules startup displays tempInfo hostName;};
      home-manager-users = builtins.mapAttrs userArgs users;
    in {
      specialArgs = {
        guiEnvironment = true;
        installSteam = false;
      };
      inherit system pkgs;
      modules =
        extraModules
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
        nixpkgs = nixpkgs-unstable;
        system = "x86_64-linux";
        timeZone = "Europe/Berlin";
        locale = "en_US.UTF-8";
        extraModules = machines.vm.hardware ++ [nixos-generators.nixosModules.all-formats];
        users = {
          user1 = {
            hashedPassword = ""; # generate with mkpasswd
            isNormalUser = true;
            extraGroups = ["wheel" "networkmanager" "video"];
            isGUIUser = true;
            gitconfig = {}; # See home-manager module
            accounts = {}; # Use mkGmailAccount or mkEmailAccount
            startup.once = [
              "ferdium --ozone-platform-hint=auto --enable-webrtc-pipewire-capturer"
              # Using native wayland cuases instant crash when interacting with the window
              # (cmd "signal-desktop --start-in-tray --ozone-platform-hint=auto --enable-webrtc-pipewire-capturer")
              "signal-desktop --start-in-tray --enable-webrtc-pipewire-capturer"
            ];
          };
          user2 = {
            hashedPassword = ""; # generate with mkpasswd
            extraGroups = ["networkmanager" "video"];
            isNormalUser = true;
          };
        };
      };
      nixosConfigurations.example-stable = mkNixOSConfig {
        nixpkgs = nixpkgs-stable;
        unstable = false;
        system = "x86_64-linux";
        timeZone = "Europe/Berlin";
        locale = "en_US.UTF-8";
        extraModules = machines.vm.hardware ++ [nixos-generators.nixosModules.all-formats];
        users = {
          user1 = {
            hashedPassword = ""; # generate with mkpasswd
            isNormalUser = true;
            extraGroups = ["wheel" "networkmanager" "video"];
            isGUIUser = true;
            gitconfig = {}; # See home-manager module
            accounts = {}; # Use mkGmailAccount or mkEmailAccount
            startup.once = [
              "ferdium --ozone-platform-hint=auto --enable-webrtc-pipewire-capturer"
              # Using native wayland cuases instant crash when interacting with the window
              # (cmd "signal-desktop --start-in-tray --ozone-platform-hint=auto --enable-webrtc-pipewire-capturer")
              "signal-desktop --start-in-tray --enable-webrtc-pipewire-capturer"
            ];
          };
          user2 = {
            hashedPassword = ""; # generate with mkpasswd
            extraGroups = ["networkmanager" "video"];
            isNormalUser = true;
          };
        };
      };
    }
    // flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs-unstable {inherit system;};
      in {
        formatter = pkgs.alejandra;
      }
    );
}
