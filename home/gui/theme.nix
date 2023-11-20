{pkgs, ...}: {
  # home.sessionVariables.GTK_THEME = "Adwaita:dark";
  stylix.cursor.package = pkgs.nordzy-cursor-theme;
  stylix.cursor.name = "Nordzy-cursors";
  home.pointerCursor.gtk.enable = true;
  gtk.enable = true;
  # gtk.theme.name = "Adwaita-dark";
  gtk.iconTheme = {
    name = "Papirus-Dark";
    package = pkgs.papirus-icon-theme;
  };
  gtk.gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
  gtk.gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
  qt.enable = true;
  qt.platformTheme = "gtk";
  # qt.style = {
  #   name = "adwaita-dark";
  #   package = pkgs.adwaita-qt;
  # };
}
