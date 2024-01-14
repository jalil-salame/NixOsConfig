{ timeZone
, locale
, users
, nixpkgs-flake
,
}: { pkgs
   , lib
   , guiEnvironment
   , ...
   }:
let
  optionalAttrValue = value: attr: lib.optional (builtins.hasAttr value attr) { ${value} = attr.${value}; };
  eza =
    if pkgs ? "eza"
    then "eza"
    else "exa";
  nerdFontSymbols = pkgs.nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; };
  fallbackSymbols = {
    name = "Symbols Nerd Font";
    package = nerdFontSymbols;
  };
in
{
  imports =
    # TODO: May not be needed after Linux 6.3
    [ ./8bitdo-fix.nix ]
    ++ lib.optional guiEnvironment ./gui;
  users.defaultUserShell = pkgs.zsh;
  programs.zsh.enable = true;

  stylix.image = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/lunik1/nixos-logo-gruvbox-wallpaper/d4937c424fad79c1136a904599ba689fcf8d0fad/png/gruvbox-dark-rainbow.png";
    sha256 = "036gqhbf6s5ddgvfbgn6iqbzgizssyf7820m5815b2gd748jw8zc";
  };
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
  stylix.polarity = "dark";
  stylix.fonts.monospace.name = "JetBrains Mono";
  stylix.fonts.monospace.package = pkgs.jetbrains-mono;
  stylix.fonts.sansSerif.name = "Noto Sans";
  stylix.fonts.sansSerif.package = pkgs.noto-fonts;
  stylix.fonts.serif.name = "Noto Serif";
  stylix.fonts.serif.package = pkgs.noto-fonts;
  stylix.fonts.fallbackFonts.monospace = [ fallbackSymbols ];
  stylix.fonts.fallbackFonts.sansSerif = [ fallbackSymbols ];
  stylix.fonts.fallbackFonts.serif = [ fallbackSymbols ];
  stylix.fonts.sizes.popups = 12;
  stylix.targets.plymouth.logoAnimated = false;
  stylix.targets.plymouth.logo = builtins.fetchurl {
    # url = "http://xenia-linux-site.glitch.me/images/cathodegaytube-splash.png";
    url = "https://efimero.github.io/xenia-images/cathodegaytube-splash.png";
    sha256 = "qKugUfdRNvMwSNah+YmMepY3Nj6mWlKFh7jlGlAQDo8=";
  };

  boot.plymouth.enable = true;

  security.pam.services.login.gnupg.enable = true;

  programs.starship.enable = true;
  programs.starship.settings = import ./starship.nix;

  environment.systemPackages = [
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
    pkgs.${eza}
  ];

  # Set your time zone.
  time = { inherit timeZone; };

  # Select internationalisation properties.
  i18n.defaultLocale = locale;
  console = {
    # font = "Lat2-Terminus16";
    # keyMap = "us";
    useXkbConfig = true; # use xkbOptions in tty.
  };
  services.xserver.layout = "us";

  networking.firewall.allowedUDPPorts = [ 5353 ]; # spotifyd
  networking.firewall.allowedTCPPorts = [ 2020 ]; # spotifyd

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users =
    let
      value =
        builtins.mapAttrs
          (
            _: value:
              lib.mkMerge ([{ inherit (value) hashedPassword; }]
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
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
