{ ... }:

{
  # DNSCrypt-Proxy — encrypted DNS resolution.
  # Listens on 127.0.0.1:53; iwd told not to manage DNS (see networking.nix).
  networking.nameservers     = [ "127.0.0.1" "::1" ];
  networking.resolvconf.enable = false;

  services.dnscrypt-proxy = {
    enable   = true;
    settings = {
      require_dnssec  = true;
      ipv6_servers    = true;
      listen_addresses = [ "127.0.0.1:53" "[::1]:53" ];
      server_names    = [
        "cloudflare"
        "adguard-default"
        "mullvad"
        "nextdns"
        "quad9-recommended-alt"
      ];
      sources.public-resolvers = {
        urls = [
          "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
          "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
        ];
        cache_file   = "/var/lib/dnscrypt-proxy2/public-resolvers.md";
        minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
        refresh_delay = 72;
      };
    };
  };

  systemd.services.dnscrypt-proxy.serviceConfig = {
    StateDirectory = "dnscrypt-proxy";
  };
}
