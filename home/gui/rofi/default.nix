{
  config,
  pkgs,
  ...
}: let
  inherit (config.wayland.windowManager) sway;
in {
  programs.rofi = {
    inherit (sway.config) terminal;
    enable = true;
    package = pkgs.rofi-wayland;
    location = "center";
    theme = ./theme.rasi;
    extraConfig = {
      show-icons = true;
      icon-theme = "Papirus-Dark";
    };
  };
}
