{ pkgs
, config
, screensaver-img
, mod
, ...
}:
let
  passmenu = "${pkgs.jpassmenu}/bin/jpassmenu";
  selectAudio = "${pkgs.audiomenu}/bin/audiomenu --menu 'fuzzel --dmenu'";
  scripts = import ./scripts.nix { inherit pkgs; };
  inherit (scripts) audio-source-notify brightness-notify;
  swayconf = config.wayland.windowManager.sway.config;
  workspaces = map toString [ 1 2 3 4 5 6 7 8 9 ];
  dirs =
    map
      (dir: {
        key = swayconf.${dir};
        arrow = dir;
        direction = dir;
      }) [ "up" "down" "left" "right" ];
  joinKeys = builtins.concatStringsSep "+";
  # Generate a keybind from a modifier prefix and a key
  keycombo = prefix: key: joinKeys (prefix ++ [ key ]);
  modKeybind = keycombo [ mod ];
  modCtrlKeybind = keycombo [ mod "Ctrl" ];
  modShiftKeybind = keycombo [ mod "Shift" ];
  modCtrlShiftKeybind = keycombo [ mod "Ctrl" "Shift" ];
  dir2resize.up = "resize grow height";
  dir2resize.down = "resize shrink height";
  dir2resize.right = "resize grow width";
  dir2resize.left = "resize shrink width";
  # Bind a key combo to an action
  genKeybind = prefix: action: key: { "${prefix key}" = "${action key}"; };
  genKey = prefix: action: genKeybind ({ key, ... }: prefix key) ({ direction, ... }: action direction);
  genArrow = prefix: action: genKeybind ({ arrow, ... }: prefix arrow) ({ direction, ... }: action direction);
  genArrowAndKey = prefix: action: key: (genKey prefix action key) // (genArrow prefix action key);
  # Move window
  moveWindowKeybinds = map (genArrowAndKey modShiftKeybind (dir: "move ${dir}")) dirs;
  # Focus window
  focusWindowKeybinds = map (genArrowAndKey modKeybind (dir: "focus ${dir}")) dirs;
  # Resize window
  resizeWindowKeybinds = map (genArrowAndKey modCtrlKeybind (dir: dir2resize.${dir})) dirs;
  # Move container to workspace
  moveWorkspaceKeybindings = map (genKeybind modShiftKeybind (number: "move container to workspace number ${number}")) workspaces;
  # Focus workspace
  focusWorkspaceKeybindings = map (genKeybind modKeybind (number: "workspace number ${number}")) workspaces;
  # Move container to Workspace and focus on it
  moveFocusWorkspaceKeybindings = map (genKeybind modCtrlShiftKeybind (number: "move container to workspace number ${number}; workspace number ${number}")) workspaces;
in
builtins.foldl' (l: r: l // r)
{
  "${mod}+Return" = "exec ${swayconf.terminal}";
  "${mod}+D" = "exec ${swayconf.menu}";
  "${mod}+P" = "exec ${passmenu}";
  "${mod}+F2" = "exec qutebrowser";
  "${mod}+Shift+Q" = "kill";
  "${mod}+F" = "fullscreen toggle";
  # Media Controls
  "${mod}+F10" = "exec ${selectAudio} select-sink";
  "${mod}+Shift+F10" = "exec ${selectAudio} select-source";
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
  (focusWindowKeybinds
    ++ moveWindowKeybinds
    ++ resizeWindowKeybinds
    ++ focusWorkspaceKeybindings
    ++ moveWorkspaceKeybindings
  ++ moveFocusWorkspaceKeybindings)
