{
  pkgs,
  config,
  screensaver-img,
  mod,
  lib,
}: let
  scripts = import ./scripts.nix {inherit pkgs;};
  inherit (scripts) select-default-audio-device audio-source-notify brightness-notify;
  swayconf = config.wayland.windowManager.sway.config;
  workspaces = map toString [1 2 3 4 5 6 7 8 9];
  dirs = map (dir: {
    key = swayconf.${dir};
    arrow = dir;
    direction = dir;
  }) ["up" "down" "left" "right"];
  joinKeys = builtins.concatStringsSep "+";
  keybind = prefix: key: joinKeys (prefix ++ [key]);
  modKeybind = keybind [mod];
  modShiftKeybind = keybind [mod "Shift"];
  set = name: value: {${name} = "${value}";};
  genKeybind = keybind: action: key: set "${keybind key}" "${action key}";
  genKey = keybind: action: genKeybind ({key, ...}: keybind key) ({direction, ...}: action direction);
  genArrow = keybind: action: genKeybind ({arrow, ...}: keybind arrow) ({direction, ...}: action direction);
  genArrowAndKey = keybind: action: key: (genKey keybind action key) // (genArrow keybind action key);
  # Move window
  moveWindowKeybinds = map (genArrowAndKey modShiftKeybind (dir: "move " + dir)) dirs;
  # Focus window
  focusWindowKeybinds = map (genArrowAndKey modKeybind (dir: "focus " + dir)) dirs;
  # Move container to workspace
  moveWorkspaceKeybindings = map (genKeybind modShiftKeybind (number: "move container to workspace number " + number)) workspaces;
  # Focus workspace
  focusWorkspaceKeybindings = map (genKeybind modKeybind (number: "workspace number " + number)) workspaces;
  # TODO: Add resize window keybindings
in
  builtins.foldl' (l: r: l // r) {
    "${mod}+Return" = "exec ${swayconf.terminal}";
    "${mod}+D" = "exec ${swayconf.menu}";
    "${mod}+P" = "exec passmenu";
    "${mod}+F2" = "exec qutebrowser";
    "${mod}+Shift+Q" = "kill";
    "${mod}+F" = "fullscreen toggle";
    # Media Controls
    "${mod}+F10" = "exec ${select-default-audio-device} sink --menu=rofi";
    "${mod}+Shift+F10" = "exec ${select-default-audio-device} source --menu=rofi";
    "XF86AudioRaiseVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ && ${audio-source-notify}";
    "XF86AudioLowerVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- && ${audio-source-notify}";
    "XF86AudioMute" = "exec wpctl set-mute   @DEFAULT_AUDIO_SINK@ toggle && ${audio-source-notify}";
    "XF86ScreenSaver" = "exec swaylock --image ${screensaver-img}";
    "XF86MonBrightnessUp" = "exec ${pkgs.light}/bin/light -A 5 && ${brightness-notify}";
    "XF86MonBrightnessDown" = "exec ${pkgs.light}/bin/light -U 5 && ${brightness-notify}";
    # Floating
    "${mod}+Space" = "floating toggle";
    "${mod}+Shift+Space" = "focus mode_toggle";
    # Scratchpad
    "${mod}+Minus" = "scratchpad show";
    "${mod}+Shift+Minus" = "move scratchpad";
    # Layout
    "${mod}+e" = "layout toggle split";
    # Session control
    "${mod}+r" = "reload";
    "${mod}+Shift+m" = "exit";
  }
  (focusWindowKeybinds ++ moveWindowKeybinds ++ focusWorkspaceKeybindings ++ moveWorkspaceKeybindings)
