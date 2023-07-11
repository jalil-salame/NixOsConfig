{
  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.home-manager.url = "github:nix-community/home-manager";

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
  }: let
    lib = import ./lib.nix;
    machines.gemini = import ./machines/gemini;
    mkNixOSConfig = {
      nixpkgs,
      system,
      hardware,
      users,
      timeZone,
      locale,
    }: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [nvim-config.overlays.default];
        config.allowUnfreePredicate = pkg:
          builtins.elem (lib.getName pkg) [
            "steam"
            "steam-run"
            "steam-original"
            "steam-runtime"
            "vscode"
            "mpv-thumbfast"
          ];
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
        import ./home {inherit isGUIUser username accounts gitconfig;};
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
      inherit lib machines mkNixOSConfig;
      nixosConfigurations.example = mkNixOSConfig {
        inherit nixpkgs;
        system = "x86_64-linux";
        timeZone = "Europe/Berlin";
        locale = "en_US.UTF-8";
        hardware = [machines.gemini];
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
