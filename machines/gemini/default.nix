# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ pkgs, ... }: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  fileSystems."/".options = [ "compress=zstd" ];
  fileSystems."/steam".options = [ "compress=zstd" ];
  fileSystems."/home".options = [ "compress=zstd" ];
  fileSystems."/nix".options = [ "compress=zstd" "noatime" ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 3;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable bluetooth
  hardware.bluetooth.enable = true;

  networking.hostName = "gemini";
  networking.networkmanager.enable = true;
  networking.interfaces.enp4s0.wakeOnLan.enable = true;

  console = {
    # font = "Lat2-Terminus16";
    # keyMap = "us";
    useXkbConfig = true; # use xkbOptions in tty.
  };

  # Fix PoE switch going to sleep
  systemd.services."ping-router" = {
    enable = true;
    description = "Continiuosly ping router to prevent PoE switch from going to sleep";
    script = ''
      ${pkgs.iputils}/bin/ping \
          "$(${pkgs.iproute2}/bin/ip route list default | sed 's/.*via \(\S\+\) .*/\1/')"
    '';
    wantedBy = [ "network-online.target" ];
    after = [ "network-online.target" ];
    serviceConfig = {
      Type = "simple";
    };
  };

  # Configure keymap in X11
  # services.xserver.xkbOptions = {
  #   "caps:swapescape" # map caps to escape.
  # };
  services.openssh.enable = true;
  services.openssh.startWhenNeeded = true;
  services.openssh.settings.AllowUsers = [ "jalil" ];

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}
