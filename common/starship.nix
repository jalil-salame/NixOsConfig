{
  format = "$time$all";
  add_newline = false;
  cmd_duration = {
    min_time = 500;
    show_milliseconds = true;
  };
  time = {
    format = "[$time](bold yellow) ";
    disabled = false;
  };
  status = {
    format = "[$signal_name$common_meaning$maybe_int](red)";
    symbol = "[✗](bold red)";
    disabled = false;
  };
  sudo.disabled = false;
}
