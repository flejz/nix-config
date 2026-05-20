{ pkgs, ... }:

{
  programs.direnv.enable = true;

  environment.systemPackages = with pkgs; [
    # Build toolchain
    gcc clang lld lldb mold musl
    cmake ninja gnumake gdb valgrind pkg-config

    # Languages
    go
    (python313.withPackages (ps: with ps; [ pygobject3 gobject-introspection ]))
    uv       # fast Python package manager
    ruff     # Python linter
    nodejs
    lua
    zig
    gleam
    numbat   # calculator with unit conversions

    # Rust cargo tools (rustup manages the toolchain)
    cargo-watch
    cargo-deny
    cargo-audit
    cargo-update
    cargo-edit
    cargo-outdated
    cargo-license
    cargo-tarpaulin
    cargo-cross
    cargo-zigbuild
    cargo-nextest
    cargo-bloat
    cargo-sweep
    bacon     # background Rust checker
    evcxr     # Rust REPL
    rust-script

    # Language servers
    python313Packages.python-lsp-server
    ruff
    typescript
    typescript-language-server
    eslint
    biome
    yaml-language-server
    taplo                          # TOML lsp + formatter
    bash-language-server
    dockerfile-language-server
    docker-compose-language-service
    vue-language-server
    lua-language-server
    marksman                       # Markdown lsp
    nil                            # Nix lsp
    nixd                           # Nix lsp (alternative)
    zls                            # Zig lsp
    gopls                          # Go lsp
    delve                          # Go debugger
    buf                            # Protobuf lsp
    cmake-language-server
    terraform-ls
    slint-lsp
    hyprls

    # Dev tools
    git
    git-lfs
    gitleaks
    lazygit
    jujutsu         # alternative VCS
    just            # task runner
    hurl            # HTTP testing
    mise            # polyglot version manager
    gh
    gh-dash         # GitHub dashboard TUI
    devenv          # per-project Nix environments
    mold            # fast linker
    grex            # regex generator
    tokei           # code statistics

    # Data tools
    jq
    sd              # sed replacement
    topgrade        # update-everything CLI
  ];
}
