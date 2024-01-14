{ pkgs
, lib
, installSteam
, unstable
, ...
}: {
  imports = [ ./ydotool.nix ] ++ lib.optional installSteam ./steam.nix;

  environment.systemPackages = [
    pkgs.gnome.adwaita-icon-theme
    pkgs.adwaita-qt
    pkgs.nordzy-cursor-theme
    pkgs.pinentry-qt
  ];

  programs.light.enable = true;

  hardware.opengl.enable = true;
  hardware.uinput.enable = true;
  hardware.steam-hardware.enable = true; # TODO rename installSteam to steamSupport and use it here

  fonts.fontDir.enable = true;

  security.polkit.enable = true;
  security.rtkit.enable = true; # Recommended for pipewire

  services.flatpak.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  services.dbus.enable = true;

  xdg.portal =
    {
      enable = true;
      wlr.enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    }
    // (
      if unstable
      then {
        config.preferred.default = "wlr"; # Default to wlr
        config.preferred."org.freedesktop.impl.portal.FileChooser" = "gtk"; # But choose files with "gtk"
      }
      else { }
    );

  programs.dconf.enable = true;
}
