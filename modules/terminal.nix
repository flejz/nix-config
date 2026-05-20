{ pkgs, ... }:

{
  programs.fish.enable = true;

  environment.systemPackages = with pkgs; [
    # Terminals
    kitty
    cool-retro-term

    # Shell tools
    starship
    zoxide
    fzf
    ripgrep
    fd
    bat
    delta
    lsd
    duf
    dust
    ncdu
    ouch      # compression Swiss army knife
    trash-cli

    # Terminal multiplexer
    zellij

    # File managers
    yazi
    chafa     # image-to-text for yazi previews

    # Search & navigation
    zoxide
    skim      # fzf alternative in Rust

    # Text processing
    sd        # sed alternative
    jq
    mdcat     # render Markdown in terminal
    hexyl     # hex viewer

    # Process & system
    procs     # ps replacement
    bottom
    btop
    htop
    kmon      # kernel module monitor

    # Network
    doggo     # DNS client (dig alternative)
    gping     # ping with graph
    speedtest-rs

    # Media in terminal
    cava      # audio visualizer
    viu       # image viewer in terminal

    # Fun / aesthetics
    cmatrix
    pipes-rs
    cbonsai
    figlet
    lolcat

    # Misc utilities
    yt-dlp
    aria2
    croc      # file transfer
    magic-wormhole-rs
    tealdeer  # tldr pages
    asciinema
    topgrade
    progress  # show progress of coreutils commands
    noti      # send notifications when commands finish
    moreutils
    file
    lsof
    tre-command  # tree alternative

    # Kanata — keyboard remapping daemon
    kanata

    # Calculator
    numbat
  ];
}
