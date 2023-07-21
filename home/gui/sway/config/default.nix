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
  cmd = command: {inherit command;};
  cmdAlways = command: {always = true;} // (cmd command);
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
    # See ../configure-gtk.nix
    (cmdAlways "configure-gtk")
    # See ../wait-sni-ready.nix
    # (cmd "wait-sni-ready && systemctl --user start sway-xdg-autostart.target")
    # Programs
    (cmd "ferdium --ozone-platform-hint=auto --enable-webrtc-pipewire-capturer")
    # Using native wayland cuases instant crash when interacting with the window
    # (cmd "signal-desktop --start-in-tray --ozone-platform-hint=auto --enable-webrtc-pipewire-capturer")
    (cmd "signal-desktop --start-in-tray --enable-webrtc-pipewire-capturer")
  ];
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
