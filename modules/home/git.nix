# modules/home/git.nix
# Git configuration via programs.git (home-manager built-in).
{ ... }: {

  programs.git = {
    enable = true;

    # GPG commit & tag signing
    signing = {
      key           = "0BE22D455E7C1770";
      signByDefault = true;  # sets commit.gpgsign = true
    };

    settings = {
      user.name  = "flejz";
      user.email = "flejz@protonmail.com";

      init.defaultBranch   = "main";
      pull.rebase          = true;
      push.autoSetupRemote = true;
      core.editor         = "nvim";
      tag.gpgSign         = true;
      merge.conflictstyle = "diff3";
      diff.colorMoved     = "default";

      alias = {
        st   = "status";
        co   = "checkout";
        lg   = "log --oneline --graph --decorate --all";
        undo = "reset --soft HEAD~1";
      };
    };
  };

  # delta is its own home-manager program (integrates with git automatically)
  programs.delta = {
    enable               = true;
    enableGitIntegration = true;
    options = {
      navigate     = true;
      light        = false;
      line-numbers = true;
    };
  };
}
