{ pkgs }:
let
  cacheFile = ''
    cache_file() {
      cache_dir="''${XDG_CACHE_HOME:-$HOME/.cache}/scripts"
      [ -d "$cache_dir" ] || mkdir -p "$cache_dir"
      echo "$cache_dir/$1"
    }
  '';
in
{
  brightness-notify = pkgs.writeShellScript "birghtness-notify" ''
    app='changedBrightness'
    icon='brightnesssettings'
    # Cache msgid
    ${cacheFile}
    msgid_file="$(cache_file "$app.msgid")"
    [ -f "$msgid_file" ] && msgid="$(cat "$msgid_file")"
    msgid="''${msgid:-0}"
    # Get brightness
    brightness="$(xbacklight -perceived -get)"
    # Send notification
    ${pkgs.libnotify}/bin/notify-send -pu low -r "$msgid" -a "$app" -i "$icon" -h int:value:"$brightness" "Brightness: $brightness%" >"$msgid_file"
  '';

  audio-source-notify = pkgs.writeShellScript "audio-source-notify" ''
    app='volumeChanged'
    icon='audio-volume'
    # Cache msgid
    ${cacheFile}
    msgid_file="$(cache_file "$app.msgid")"
    [ -f "$msgid_file" ] && msgid="$(cat "$msgid_file")"
    msgid="''${msgid:-0}"
    # Process volume info
    volume="$(wpctl get-volume @DEFAULT_SINK@)"
    if [ "''${volume#*MUTED}" = "$volume" ]; then
        muted=false
    else
        muted=true
    fi
    volume="''${volume#Volume: }"
    int_volume="$(printf '%.0f' "$(echo "100*$volume" | "${pkgs.bc}/bin/bc")")"
    if [ "$int_volume" -eq 0 ]; then
        muted=true
    fi
    # Send notification
    if [ "$muted" = true ]; then
      ${pkgs.libnotify}/bin/notify-send -pu low -r "$msgid" -a "$app" -i "$icon-muted" "Volume Muted" >"$msgid_file"
    else
      ${pkgs.libnotify}/bin/notify-send -pu low -r "$msgid" -a "$app" -i "$icon-high" -h "int:value:$int_volume" "Volume: $int_volume%" >"$msgid_file"
    fi
  '';

  select-default-audio-device = pkgs.writers.writePython3 "set-default-audio-device" { } ''
    import subprocess
    from argparse import ArgumentParser
    from dataclasses import dataclass
    from enum import auto
    from enum import Enum


    class Type(Enum):
        Source = auto()
        Sink = auto()

        def __str__(self) -> str:
            match self:
                case Type.Sink:
                    return "Sink"
                case Type.Source:
                    return "Source"


    def audio_type(type_str: str) -> Type:
        match type_str.lower():
            case "sink" | "sinks":
                return Type.Sink
            case "source" | "sources":
                return Type.Source

        raise ValueError(f"{type_str} is not a valid audio device type")


    @dataclass
    class Device:
        id: int
        name: str
        muted: bool
        volume: int
        default: bool

        def __str__(self) -> str:
            volume_str = "MUTED" if self.muted else f" {self.volume: 3}%"

            if self.default:
                return f"[{volume_str}] {self.name}"

            return f" {volume_str}  {self.name}"

        def __repr__(self) -> str:
            if self.default:
                return f"[{self.id}]: {self.name}"

            return f" {self.id} : {self.name}"


    def parse_audio_device(string: str) -> Device:
        device = string.strip()[1:].strip()
        is_default = False

        if device[0] == "*":
            device = device[1:].strip()
            is_default = True

        id, name, *_ = device.split(sep=". ")
        vol_ix: int = name.index("[vol: ")
        _, vol_str, *muted = name[vol_ix:].split(" ")

        if not muted:
            vol_str = vol_str[:-1]

        volume = int(vol_str.replace(".", ""))

        name = name[:vol_ix].strip()

        return Device(int(id), name, muted != [], volume, is_default)


    def get_audio_devices(type: Type) -> list[Device] | None:
        output = subprocess.run(["wpctl", "status"], capture_output=True)
        output.check_returncode()

        stdout = output.stdout.decode("UTF-8")
        devices: None | list[Device] = None
        in_sinks = False

        type_str = f"{type}s"

        for line in stdout.splitlines():
            if devices is None and not line.startswith("Audio"):
                continue
            elif devices is None:
                devices = []
                continue
            elif type_str in line:
                in_sinks = True
                continue
            elif not in_sinks:
                continue

            if not line or line.strip() == "│":
                break

            devices.append(parse_audio_device(line))

        return devices


    def select_default_device(
        devices: list[Device], menu: str, type: Type
    ) -> int | None:
        device_map = {str(device).strip(): device.id for device in devices}

        output = subprocess.run(
            [menu, "-p", f"Select {type}"],
            input=bytes("\n".join(map(str, devices)), "UTF-8"),
            capture_output=True,
        )
        selected = output.stdout.decode("UTF-8").strip()

        if not selected:
            return None

        return device_map[selected]


    def main() -> None:
        parser = ArgumentParser(
            description="A wrapper around wpctl to select the default audio device"
        )
        parser.add_argument(
            "-m",
            "--menu",
            default="dmenu",
            help="The dmenu compatible menu to use",
        )
        parser.add_argument(
            "TYPE",
            type=audio_type,
            help=f"Type of device to select (either {Type.Source} or {Type.Sink})",
        )
        args = parser.parse_args()

        devices = get_audio_devices(args.TYPE)

        if devices is None:
            return

        id = select_default_device(devices, args.menu, args.TYPE)
        if id is None:
            return

        subprocess.run(["wpctl", "set-default", str(id)]).check_returncode()


    if __name__ == "__main__":
        main()
  '';
}
