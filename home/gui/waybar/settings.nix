{
  mainBar = {
    # Bar Configguration
    layer = "top";
    position = "top";
    height = 30;
    spacing = 4;
    # Modules
    modules-left = ["sway/workspaces"];
    modules-center = ["sway/window"];
    modules-right = [
      "network"
      "battery"
      "cpu"
      "temperature"
      "memory"
      "clock"
      "pulseaudio"
      "idle_inhibitor"
      "tray"
    ];
    # Module configuration
    battery = {
      bat = "BAT0";
      interval = 60;
      states = {
        warning = 30;
        critical = 15;
      };
      format = "{icon} {capacity}%";
      format-icons = ["" "" "" "" ""];
      max-length = 25;
    };
    temperature = {
      interval = 1;
      hwmon-path = "/sys/class/hwmon/hwmon1/temp2_input";
      critical-threshold = 80;
      format-critical = " {temperatureC}°C";
      format = " {temperatureC}°C";
    };
    network = {
      format = "{ifname}";
      format-wifi = " {essid} ({signalStrength}%)";
      format-ethernet = " {ipaddr}/{cidr}";
      format-disconnected = "{ifname} Disconnected";
      tooltip-format = " {ifname} via {gwaddr}";
      tooltip-format-wifi = " {essid} ({signalStrength}%)";
      tooltip-format-ethernet = " {ifname}";
      tooltip-format-disconnected = "Disconnected";
      max-length = 50;
    };
    idle_inhibitor = {
      format = "{icon}";
      format-icons = {
        activated = "";
        deactivated = "";
      };
    };
    cpu = {
      format = "{icon}";
      format-icons = ["▁" "▂" "▃" "▄" "▅" "▆" "▇" "█"];
    };
    memory = {
      interval = 30;
      format = " {used:0.1f}G/{total:0.1f}G";
    };
    wireplumber = {
      format = " {volume}%";
      format-muted = "";
      on-click = "helvum";
    };
    pulseaudio = {
      format = "<big>{icon}</big> {volume}%";
      format-muted = "";
      format-icons = {
        headphone = "";
        hands-free = "";
        headset = "";
        phone = "";
        portable = "";
        car = "";
        default = ["" ""];
      };
      on-click = "helvum";
    };
    clock = {
      tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
      interval = 1;
      format = "{:%F %T}";
      format-alt = "{:%F}";
    };
    tray = {
      spacing = 10;
    };
  };
}
