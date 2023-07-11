{
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    style = ./new-style.css;
    settings = import ./new-settings.nix;
  };
}
