{
  config,
  pkgs,
  mod,
  terminal,
  menu,
  background,
  lib,
  startup ? {
    once = [];
    always = [];
  },
}: let
  modifier = mod;
  keybindings = import ./keybindings.nix {
    inherit mod config pkgs lib;
    screensaver-img = background;
  };
  cmd = command: {inherit command;};
  cmdAlways = command: {
    inherit command;
    always = true;
  };
  # Populate if missing
  startOnce =
    if builtins.hasAttr "once" startup
    then startup.once
    else [];
  startAlways =
    if builtins.hasAttr "always" startup
    then startup.always
    else [];
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
  startup =
    [
      # See ../configure-gtk.nix
      (cmdAlways "configure-gtk")
      # See ../wait-sni-ready.nix
      # (cmd "wait-sni-ready && systemctl --user start sway-xdg-autostart.target")
    ]
    ++ (builtins.map cmdAlways startAlways)
    ++ (builtins.map cmd startOnce);
  # Input configuration
  input."type:keyboard" = {
    repeat_delay = "300";
    repeat_rate = "50";
    xkb_options = "caps:swapescape";
    xkb_numlock = "enabled";
  };
  input."type:touchpad" = {
    click_method = "clickfinger";
    natural_scroll = "enabled";
    scroll_method = "two_finger";
    tap = "enabled";
    tap_button_map = "lrm";
  };
}
