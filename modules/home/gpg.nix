{ pkgs, ... }: {

  programs.gpg = {
    enable = true;
    settings = {
      keyid-format    = "long";
      with-fingerprint = true;
    };
  };

  services.gpg-agent = {
    enable          = true;
    defaultCacheTtl = 3600;
    maxCacheTtl     = 7200;
    # pinentry-all auto-selects gnome3/gtk2/qt based on the running session
    pinentryPackage = pkgs.pinentry-all;
  };
}
