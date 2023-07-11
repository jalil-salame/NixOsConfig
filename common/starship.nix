# let
#   sep = (fg: bg: "[\](fg:${fg} bg:${bg})");
#   logo = "[░▒▓](#ebdbb2)[ \ ](fg:#458588 bg:#ebdbb2)${sep "#ebdbb2" "#3c3836"}";
#   time = "$time${sep "#3c3836" "#fe8019"}";
#   directory = "$directory${sep "#fe8019" "#504945"}";
#   git = "$git_branch$git_status${sep "#504945" "#3c3836"}";
#   toolchains = "$c$cmake$go$haskell$java$kotlin[\ ](fg:#3c3836)";
# in
{
  format = "[\](fg:#458588)$time$all"; # "${logo}${time}${directory}${git}${toolchains}\n$cmd__duration$character";
  add_newline = false;
  cmd_duration = {
    min_time = 500;
    show_milliseconds = true;
  };
  time = {
    format = "[  $time](bold yellow) ";
    disabled = false;
  };
  status = {
    format = "[$signal_name$common_meaning$maybe_int](red)";
    symbol = "[✗](bold red)";
    disabled = false;
  };
  sudo.disabled = false;
}
