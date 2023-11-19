{
  isGUIUser,
  username,
  accounts,
  gitconfig,
  extraHomeModules,
  startup,
  displays,
  tempInfo,
  hostName,
}: {
  lib,
  nvim-modules,
  ...
}: {
  imports =
    [
      (import ./common.nix {inherit hostName;})
      nvim-modules.nixneovim
      nvim-modules.nvim-config
    ]
    ++ extraHomeModules
    ++ lib.optional isGUIUser (import ./gui {inherit tempInfo startup displays;});

  home = {
    inherit username;
    homeDirectory = "/home/${username}";
    stateVersion = "22.11";
  };

  accounts.email = {inherit accounts;};

  programs.git =
    {
      enable = true;
      delta.enable = true;
      lfs.enable = true;
      extraConfig = {
        init.defaultBranch = "main";
      };
    }
    // gitconfig;

  programs.home-manager.enable = true;
}
