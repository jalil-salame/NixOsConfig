{pkgs, ...}: {
  environment.systemPackages = [pkgs.ydotool];
  systemd.user.services.ydotool = {
    enable = true;
    wantedBy = ["default.target"];
    description = "Generic command-line automation tool";
    documentation = ["man:ydotool(1)" "man:ydotoold(8)"];
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      ExecStart = "${pkgs.ydotool}/bin/ydotoold";
      ExecReload = "${pkgs.util-linux}/bin/kill -HUP $MAINPID";
      KillMode = "process";
      TimeoutSec = 180;
    };
  };
}
