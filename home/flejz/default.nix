# home/flejz/default.nix
# Home Manager entrypoint for user flejz.
# Imports all home modules — add new modules here.
{ ... }: {
  imports = [
    ../../modules/home/packages.nix
    ../../modules/home/shell.nix
    ../../modules/home/git.nix
    ../../modules/home/gpg.nix
    ../../modules/home/dotfiles.nix
  ];

  home.username    = "flejz";
  home.homeDirectory = "/home/flejz";

  # Match system.stateVersion in config.nix.
  home.stateVersion = "25.11";
}
