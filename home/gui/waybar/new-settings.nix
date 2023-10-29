{tempInfo, ...}: {
  mainBar = {
    "layer" = "top"; # Waybar at top layer
    "position" = "top"; # Waybar position (top|bottom|left|right)
    # "height" = 30; # Waybar height (to be removed for auto height)
    "margin" = "2 2 2 2";
    # "width" = 1280; # Waybar width
    # Choose the order of the modules
    "modules-left" = ["sway/workspaces"];
    "modules-center" = ["clock"];
    "modules-right" =
      ["pulseaudio" "backlight" "battery" "sway/language"]
      ++ (
        if tempInfo == null
        then []
        else ["temperature"]
      )
      ++ ["memory" "tray"];

    #***************************
    #*  Modules configuration  *
    #***************************

    "sway/workspaces" = {
      "disable-scroll" = true;
      "persistent_workspaces" = {
        "1" = [];
        "2" = [];
        "3" = [];
        "4" = [];
        "5" = [];
        "6" = [];
        "7" = [];
        "8" = [];
        "9" = [];
      };
    };

    "sway/language" = {
      "format" = "{} ";
      "min-length" = 5;
      "tooltip" = false;
    };

    "memory" = {
      "format" = "{used:0.1f}/{total:0.1f}GiB ";
      "interval" = 3;
    };

    "clock" = {
      "timezone" = "Europe/Berlin";
      "tooltip-format" = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
      "format" = "{:%a, %d %b, %H:%M}";
    };

    "pulseaudio" = {
      # "scroll-step" = 1; # %, can be a float
      "reverse-scrolling" = 1;
      "format" = "{volume}% {icon} {format_source}";
      "format-bluetooth" = "{volume}% {icon} {format_source}";
      "format-bluetooth-muted" = "{volume}% 󰖁 {icon} {format_source}";
      "format-muted" = "{volume}% 󰖁 {format_source}";
      "format-source" = "{volume}% ";
      "format-source-muted" = "{volume}% 󰍭";
      "format-icons" = {
        "headphone" = "󰋋";
        "hands-free" = "";
        "headset" = "󰋎";
        "phone" = "󰘂";
        "portable" = "";
        "car" = "";
        "default" = ["󰕿" "󰖀" "󰕾"];
      };
      "on-click" = "pavucontrol";
      "min-length" = 13;
    };

    "temperature" =
      if tempInfo == null
      then {}
      else {
        # TODO: insert from hardware config
        inherit (tempInfo) thermal-zone hwmon-path;
        "critical-threshold" = 80;
        # "format-critical" = "{temperatureC}°C {icon}";
        "format" = "{temperatureC}°C {icon}";
        "format-icons" = ["" "" "" "" ""];
        "tooltip" = false;
      };

    "backlight" = {
      "device" = "intel_backlight";
      "format" = "{percent}% {icon}";
      "format-icons" = ["󰃚" "󰃛" "󰃜" "󰃝" "󰃞" "󰃟" "󰃠"];
      "min-length" = 7;
    };

    "battery" = {
      "states" = {
        "warning" = 30;
        "critical" = 15;
      };
      "format" = "{capacity}% {icon}";
      "format-charging" = "{capacity}% 󰂄";
      "format-plugged" = "{capacity}% 󰚥";
      "format-alt" = "{time} {icon}";
      "format-icons" = ["󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹"];
      # "on-update" = "$HOME/.config/waybar/scripts/check_battery.sh";
    };

    "tray" = {
      "icon-size" = 16;
      "spacing" = 0;
    };
  };
}
