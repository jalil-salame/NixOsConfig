{
  # Change back once gitoxide 0.30.0 lands
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  # inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
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
    machines.gemini.tempInfo.hwmon-path = "/sys/class/hwmon/hwmon2/temp2_input"; # Tdie
    machines.gemini.hardware = [
      (import ./machines/gemini)
      nixos-hardware.nixosModules.common-pc
      nixos-hardware.nixosModules.common-pc-hdd
      nixos-hardware.nixosModules.common-pc-ssd
      nixos-hardware.nixosModules.common-cpu-amd
      nixos-hardware.nixosModules.common-gpu-amd
    ];
    machines.capricorn.tempInfo.hwmon-path = "/sys/class/hwmon/hwmon2/temp1_input";
    machines.capricorn.hardware = [
      (import ./machines/capricorn)
      nixos-hardware.nixosModules.common-pc-laptop
      nixos-hardware.nixosModules.common-pc-laptop-hdd
      nixos-hardware.nixosModules.common-pc-laptop-ssd
      nixos-hardware.nixosModules.common-cpu-intel
    ];
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
    mkNixOSConfig = {
      nixpkgs, # The nixpkgs input to use (should be nixos-unstable)
      system, # System hardware; i.e. "x86_64-linux" or "aarch64-linux"
      users, # The users to setup, see the example config
      timeZone, # The system's time zone; i.e. "Europe/Berlin"
      locale, # The system's locale; i.e. "en_US.UTF-8"
      hostName ? null, # The system's hostName
      tempInfo ? null, # Temperature sensor to monitor
      unfree ? [], # What unfree packages to allow
      extraModules ? [], # Extra NixOs modules to enable
      extraHomeModules ? [], # Extra home-manager modules to enable
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
        startup ? null,
        ...
      }:
        import ./home {inherit isGUIUser username accounts gitconfig extraHomeModules startup tempInfo hostName;};
      home-manager-users = builtins.mapAttrs userArgs users;
    in
      nixpkgs.lib.nixosSystem {
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
        inherit nixpkgs;
        system = "x86_64-linux";
        timeZone = "Europe/Berlin";
        locale = "en_US.UTF-8";
        # gemini's hardware includes rocm support (+3 GiB)
        extraModules = machines.capricorn.hardware;
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
        pkgs = import nixpkgs {inherit system;};
      in {
        formatter = pkgs.alejandra;
      }
    );
}
