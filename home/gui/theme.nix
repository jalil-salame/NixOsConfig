{
  pkgs,
  unstable,
  ...
}: let
  cursor.package = pkgs.nordzy-cursor-theme;
  cursor.name = "Nordzy-cursors";
in {
  # home.sessionVariables.GTK_THEME = "Adwaita:dark";
  stylix =
    if unstable
    then {inherit cursor;}
    else {};
  home.pointerCursor =
    {gtk.enable = true;}
    // (
      if unstable
      then {}
      else {inherit (cursor) name package;}
    );
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
