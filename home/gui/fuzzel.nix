{config, ...}: let
  inherit (config.wayland.windowManager) sway;
in {
  programs.fuzzel.enable = true;
  programs.fuzzel.settings.icon-theme = "Papirus-Dark";
  programs.fuzzel.settings.terminal = sway.config.terminal;
}
