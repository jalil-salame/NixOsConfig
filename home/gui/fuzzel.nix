{ config, ... }:
let
  inherit (config.wayland.windowManager) sway;
in
{
  programs.fuzzel.enable = true;
  programs.fuzzel.settings.main.icon-theme = "Papirus-Dark";
  programs.fuzzel.settings.main.terminal = sway.config.terminal;
  programs.fuzzel.settings.main.layer = "overlay";
}
