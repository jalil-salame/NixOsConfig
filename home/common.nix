{
  config,
  pkgs,
  ...
}: {
  imports = [];

  home.packages = [
    pkgs.gopass
    pkgs.sshfs
    pkgs.gitoxide
    pkgs.xplr
    # Developer toolchains
    pkgs.rustup
  ];

  home.shellAliases = {
    # Verbose Commands
    cp = "cp --verbose";
    ln = "ln --verbose";
    mv = "mv --verbose";
    mkdir = "mkdir --verbose";
    rename = "rename --verbose";
    # Add Color
    grep = "grep --color=auto";
    ip = "ip --color=auto";
    # Use exa
    tree = "exa --tree";
  };
  home.sessionVariables = {
    CARGO_HOME = "${config.xdg.dataHome}/cargo";
    RUSTUP_HOME = "${config.xdg.dataHome}/rustup";
    GOPATH = "${config.xdg.dataHome}/go";
  };

  programs.himalaya.enable = true;

  services.spotifyd = {
    enable = true;
    settings.global = {
      device_name = "gemini";
      device_type = "computer";
      backend = "pulseaudio";
      zeroconf_port = 2020;
    };
  };

  programs.password-store = {
    enable = true;
    package = pkgs.pass-wayland;
    settings = {
      PASSWORD_STORE_DIR = "${config.xdg.dataHome}/pass";
    };
  };
  programs.ssh = {
    enable = true;
    matchBlocks."mufupi" = {
      hostname = "mufu.cloudns.nz";
      identityFile = config.home.homeDirectory + "/.ssh/id_ed25519";
    };
    matchBlocks."ditcpi" = {
      hostname = "192.168.178.185";
      identityFile = config.home.homeDirectory + "/.ssh/id_ed25519";
    };
  };

  programs.gpg = {
    enable = true;
    homedir = "${config.xdg.dataHome}/gnupg";
  };

  services.gpg-agent = {
    enable = true;
    maxCacheTtl = 86400;
    pinentryFlavor = "qt";
    extraConfig = "allow-preset-passphrase";
  };

  # Private Value
  xdg.configFile."pam-gnupg".text = ''
    ${config.programs.gpg.homedir}
    036284EE75E5FB14119A43D44F087B5EC0961274
  '';

  programs.exa = {
    enable = true;
    enableAliases = true;
    git = true;
    icons = true;
  };

  programs.lazygit.enable = true;
  programs.zoxide.enable = true;
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    autocd = true;
    dotDir = ".config/zsh";
    history = {
      path = "${config.xdg.dataHome}/zsh/zsh_history";
    };
  };
  programs.direnv.enable = true;
  programs.direnv.nix-direv.enable = true;

  programs.gitui = {
    enable = true;
    keyConfig = ''
      // bit for modifiers
      // bits: 0  None
      // bits: 1  SHIFT
      // bits: 2  CONTROL
      //
      // Note:
      // If the default key layout is lower case,
      // and you want to use `Shift + q` to trigger the exit event,
      // the setting should like this `exit: Some(( code: Char('Q'), modifiers: ( bits: 1,),)),`
      // The Char should be upper case, and the shift modified bit should be set to 1.
      //
      // Note:
      // find `KeysList` type in src/keys/key_list.rs for all possible keys.
      // every key not overwritten via the config file will use the default specified there
      (
          open_help: Some(( code: F(1), modifiers: ( bits: 0,),)),

          move_left: Some(( code: Char('h'), modifiers: ( bits: 0,),)),
          move_right: Some(( code: Char('l'), modifiers: ( bits: 0,),)),
          move_up: Some(( code: Char('k'), modifiers: ( bits: 0,),)),
          move_down: Some(( code: Char('j'), modifiers: ( bits: 0,),)),

          popup_up: Some(( code: Char('p'), modifiers: ( bits: 2,),)),
          popup_down: Some(( code: Char('n'), modifiers: ( bits: 2,),)),
          page_up: Some(( code: Char('b'), modifiers: ( bits: 2,),)),
          page_down: Some(( code: Char('f'), modifiers: ( bits: 2,),)),
          home: Some(( code: Char('g'), modifiers: ( bits: 0,),)),
          end: Some(( code: Char('G'), modifiers: ( bits: 1,),)),
          shift_up: Some(( code: Char('K'), modifiers: ( bits: 1,),)),
          shift_down: Some(( code: Char('J'), modifiers: ( bits: 1,),)),

          edit_file: Some(( code: Char('I'), modifiers: ( bits: 1,),)),

          status_reset_item: Some(( code: Char('U'), modifiers: ( bits: 1,),)),

          diff_reset_lines: Some(( code: Char('u'), modifiers: ( bits: 0,),)),
          diff_stage_lines: Some(( code: Char('s'), modifiers: ( bits: 0,),)),

          stashing_save: Some(( code: Char('w'), modifiers: ( bits: 0,),)),
          stashing_toggle_index: Some(( code: Char('m'), modifiers: ( bits: 0,),)),

          stash_open: Some(( code: Char('l'), modifiers: ( bits: 0,),)),

          abort_merge: Some(( code: Char('M'), modifiers: ( bits: 1,),)),
      )
    '';
  };

  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };
}
