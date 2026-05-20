{ pkgs, ... }:

{
  # Greetd + Tuigreet — replaces GDM.
  # GDM must be disabled in system.nix (hyprland block).
  services.greetd = {
    enable   = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet \
          --time \
          --time-format '%I:%M %p | %a • %h | %F' \
          --sessions /run/current-system/sw/share/wayland-sessions";
        user = "greeter";
      };
    };
  };

  users.users.greeter = {
    isNormalUser = false;
    description  = "greetd greeter user";
    extraGroups  = [ "video" "audio" ];
  };

  environment.systemPackages = with pkgs; [
    tuigreet
  ];
}
