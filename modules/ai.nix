{ pkgs, config, ... }:

{
  # Ollama — local LLM server. Models are NOT pre-loaded; run `ollama pull <model>` yourself.
  services.ollama = {
    enable = true;
    # loadModels = [ ];  # add model names here to pre-pull on activation
  };

  # SearXNG — self-hosted private search engine on port 7777.
  # Set a real secret key: `head -c 32 /dev/urandom | base64`
  services.searx = {
    enable   = true;
    settings = {
      server = {
        port          = 7777;
        bind_address  = "127.0.0.1";
        secret_key    = "CHANGE_ME_generate_with_openssl_rand_hex_32";
      };
      search.formats = [ "html" "json" ];
    };
  };

  services.open-webui = {
    enable = true;
    port   = 8888;
    host   = "127.0.0.1";
  };

  environment.systemPackages = with pkgs; [
    oterm       # TUI Ollama client
    aichat      # multi-model CLI/REPL
    fabric-ai   # AI prompt toolkit
  ];
}
