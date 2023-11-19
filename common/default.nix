{
  timeZone,
  locale,
  users,
  nixpkgs-flake,
}: {
  pkgs,
  lib,
  guiEnvironment,
  ...
}: let
  optionalAttrValue = value: attr: lib.optional (builtins.hasAttr value attr) {${value} = attr.${value};};
in {
  # TODO: May not be needed after Linux 6.3
  imports = [./8bitdo-fix.nix] ++ lib.optional guiEnvironment ./gui;
  users.defaultUserShell = pkgs.zsh;
  programs.zsh.enable = true;

  boot.plymouth = {
    enable = true;
    theme = "spinner";
    logo = pkgs.fetchurl {
      # url = "http://xenia-linux-site.glitch.me/images/cathodegaytube-splash.png";
      url = "https://efimero.github.io/xenia-images/cathodegaytube-splash.png";
      sha256 = "qKugUfdRNvMwSNah+YmMepY3Nj6mWlKFh7jlGlAQDo8=";
    };
  };

  security.pam.services.login.gnupg.enable = true;

  programs.starship.enable = true;
  programs.starship.settings = import ./starship.nix;

  environment.systemPackages =
    [
      # Dev tools
      pkgs.gcc
      pkgs.just
      pkgs.clang
      # CLI tools
      pkgs.fd
      pkgs.bat
      pkgs.skim
      pkgs.ripgrep
      pkgs.du-dust
      pkgs.curl
      pkgs.wget
    ]
    ++ [(
      if builtins.hasAttr "eza" pkgs
      then pkgs.eza
      else pkgs.exa
    )];

  # Set your time zone.
  time = {inherit timeZone;};

  # Select internationalisation properties.
  i18n.defaultLocale = locale;
  console = {
    # font = "Lat2-Terminus16";
    # keyMap = "us";
    useXkbConfig = true; # use xkbOptions in tty.
  };
  services.xserver.layout = "us";

  networking.firewall.allowedUDPPorts = [5353]; # spotifyd
  networking.firewall.allowedTCPPorts = [2020]; # spotifyd

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users = let
    value =
      builtins.mapAttrs (
        _: value:
          lib.mkMerge ([{inherit (value) hashedPassword;}]
            ++ optionalAttrValue "extraGroups" value
            ++ optionalAttrValue "isNormalUser" value
            ++ optionalAttrValue "isSystemUser" value
            ++ optionalAttrValue "openssh" value
            ++ optionalAttrValue "packages" value)
      )
      users;
  in
    value;

  nix.gc.automatic = true;
  nix.gc.dates = "weekly";
  nix.gc.options = "--delete-older-than 30d";
  # run between 0 and 45min after boot if run was missed
  nix.gc.randomizedDelaySec = "45min";
  nix.registry.nixpkgs.flake = nixpkgs-flake;
  nix.settings.auto-optimise-store = true;
  nix.settings.experimental-features = ["nix-command" "flakes"];
}
