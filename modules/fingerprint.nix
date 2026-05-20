{ ... }:

{
  # fprintd — Synaptics Prometheus MIS (06cb:00bd), supported by mainline libfprint.
  # After enabling, enroll: `fprintd-enroll -f right-index-finger`
  # Verify: `fprintd-verify`
  services.fprintd.enable = true;
}
