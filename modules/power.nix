{ pkgs, ... }:

{
  services.auto-cpufreq.enable          = false;
  services.power-profiles-daemon.enable = false;
  services.thermald.enable              = true;
  services.upower.enable                = true;

  services.tlp = {
    enable   = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC  = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";

      CPU_BOOST_ON_AC  = 1;
      CPU_BOOST_ON_BAT = 0;

      RUNTIME_PM_ON_AC  = "on";
      RUNTIME_PM_ON_BAT = "auto";

      PCIE_ASPM_ON_AC  = "default";
      PCIE_ASPM_ON_BAT = "powersave";
    };
  };

  environment.systemPackages = with pkgs; [
    poweralertd
  ];
}
