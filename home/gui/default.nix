{
  tempInfo,
  startup,
  displays,
}: {
  pkgs,
  config,
  ...
}: {
  imports = [
    (import ./sway {inherit tempInfo startup displays;})
    ./theme.nix
  ];

  home.packages = [
    pkgs.webcord
    pkgs.qutebrowser
    pkgs.firefox
    pkgs.ferdium
    pkgs.xournalpp
    pkgs.signal-desktop
    pkgs.dmenu-wayland
    pkgs.lxqt.pcmanfm-qt
    # Sway pkgs
    pkgs.wayland
    pkgs.xdg-utils
    pkgs.glib
    pkgs.gnome3.adwaita-icon-theme
    pkgs.swaylock
    pkgs.swayidle
    pkgs.grim
    pkgs.slurp
    pkgs.wl-clipboard
    pkgs.mako
    pkgs.wdisplays
    # Fonts
    pkgs.noto-fonts
    pkgs.noto-fonts-cjk
    pkgs.noto-fonts-emoji
    pkgs.jetbrains-mono
    (pkgs.nerdfonts.override {fonts = ["Noto"];})
  ];

  programs.qutebrowser = {
    enable = true;
    keyBindings.normal = {
      ",d" = "hint links download";
      ",y" = "hint links yank";
      ",p" = "spawn --userscript qute-pass";
    };
  };

  xdg.systemDirs.data = [
    "/usr/share"
    "/var/lib/flatpak/exports/share"
    "${config.xdg.dataHome}/flatpak/exports/share"
  ];

  fonts.fontconfig.enable = true;

  programs.zathura.enable = true;
  programs.wezterm = import ./wezterm.nix;
  programs.mpv.enable = true;
  programs.mpv.scripts = builtins.attrValues {inherit (pkgs.mpvScripts) uosc thumbfast;};
}
