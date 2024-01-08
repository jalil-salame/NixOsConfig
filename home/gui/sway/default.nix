{
  tempInfo,
  startup,
  displays,
}: {
  config,
  pkgs,
  lib,
  ...
}: let
  configure-gtk = pkgs.writeTextFile (import ./configure-gtk.nix {inherit pkgs config;});
  wait-sni-ready = import ./wait-sni-ready.nix {inherit pkgs;};
  mod = "Mod4";
  terminal = "wezterm";
  rofi = config.programs.rofi.finalPackage;
  menu = "${rofi}/bin/rofi -run-command 'swaymsg exec -- {cmd}' -run-shell-command 'swaymsg exec -- {terminal} -e {cmd}' -modi 'run,drun' -show drun";
  background = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/lunik1/nixos-logo-gruvbox-wallpaper/d4937c424fad79c1136a904599ba689fcf8d0fad/png/gruvbox-dark-rainbow.png";
    sha256 = "036gqhbf6s5ddgvfbgn6iqbzgizssyf7820m5815b2gd748jw8zc";
  };
  config_ = import ./config {inherit config mod terminal menu background lib pkgs startup;};
in {
  imports = [../rofi (import ../waybar {inherit tempInfo;})];
  home.packages = [configure-gtk wait-sni-ready];
  wayland.windowManager.sway = {
    enable = true;
    config = config_;
  };
  # Notifications
  services.mako.enable = true;
  services.mako.layer = "overlay";
  services.mako.borderRadius = 8;
  services.mako.defaultTimeout = 15000;
  # Automatically configure outputs
  services.kanshi.enable = true;
  services.kanshi.profiles = displays;
  # systemd.user.targets.sway-xdg-autostart = {
  #   # Systemd provides xdg-desktop-autostart.target as a way to process XDG autostart
  #   # desktop files. The target sets RefuseManualStart though, and thus cannot be
  #   # used from scripts.
  #   Unit = {
  #     Description = "XDG autostart for Sway session";
  #     Documentation = "man:systemd.special(7) man:systemd-xdg-autostart-generator(8)";
  #     BindsTo = "xdg-desktop-autostart.target";
  #     PartOf = "sway-session.target";
  #     After = "sway-session.target";
  #   };
  # };
}
