{ config, pkgs, lib, ... }:

{
  isoImage.makeEfiBootable = true;
  isoImage.makeUsbBootable = true;

  services.xserver = {
    enable = true;
    desktopManager = {
      xterm.enable = false;
      xfce.enable = true;
    };
    displayManager.defaultSession = "xfce";
    displayManager.autoLogin.enable = true;
    displayManager.autoLogin.user = "deelnemer";
  };

  networking.hostName = "vinylsnijder"; # Define your hostname.
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Amsterdam";

  services.printing = {
    enable = true;
    # TODO do we need to add the 'raw' driver here?
  };

  users.users.deelnemer = {
    isNormalUser = true;
  };

  environment.systemPackages = with pkgs; [
    firefox
    (inkscape-with-extensions.override {
      inkscapeExtensions = [
        inkscape-extensions.inkcut
      ];
    })
  ];
}
