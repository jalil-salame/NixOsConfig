{
  config,
  pkgs,
  mod,
  terminal,
  menu,
  background,
  lib,
  ...
}: let
  modifier = mod;
  keybindings = import ./keybindings.nix {
    inherit mod config pkgs lib;
    screensaver-img = background;
  };
in {
  inherit modifier terminal menu keybindings;
  # Appearance
  bars = []; # Waybar is started as a systemd service
  gaps = {
    smartGaps = true;
    smartBorders = "on";
    inner = 4;
  };
  seat."*".xcursor_theme = "Nordzy-cursors";
  output."*".bg = "${background} fill";
  colors = import ./colors.nix;
  window = import ./window.nix;
  # Startup scripts
  startup = [
    {
      # See ../configure-gtk.nix
      command = "configure-gtk";
      always = true;
    }
    # {
    #   # See ../wait-sni-ready.nix
    #   command = "wait-sni-ready && systemctl --user start sway-xdg-autostart.target";
    # }
    # Programs
    {command = "ferdium --ozone-platform-hint=auto --enable-webrtc-pipewire-capturer";}
    {command = "signal-desktop --start-in-tray --ozone-platform-hint=auto --enable-webrtc-pipewire-capturer";}
  ];
  # Input configuration
  input = {
    "type:keyboard" = {
      repeat_delay = "300";
      repeat_rate = "50";
      xkb_options = "caps:swapescape";
      xkb_numlock = "enabled";
    };
  };
}
