{ config, pkgs, lib, ... }:


let
  # TODO explicit "/.git" filter is needed until 
  # https://github.com/NixOS/nixpkgs/pull/94960 is in nixos-unstable
  nixpkgs-without-git-metadata = pkgs.nix-gitignore.gitignoreSource [ "/.git" ] <nixpkgs>;
in
{
  imports = [
    # TODO fetch a particular version
    (import "${builtins.fetchTarball https://github.com/rycee/home-manager/archive/master.tar.gz}/nixos")
  ];

  nix.nixPath = [ "nixpkgs=${nixpkgs-without-git-metadata}" "nixos-config=/etc/nixos/configuration.nix" ];
  isoImage.makeEfiBootable = true;
  isoImage.makeUsbBootable = true;

  isoImage.appendToMenuLabel = " Makersplaats Vinylsnijder";
  isoImage.splashImage = ./bios-boot.png;
  isoImage.efiSplashImage = ./bios-boot.png;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.extraModulePackages = [
    # For the tp-link TP-WN823N
    config.boot.kernelPackages.rtl8192eu

  ];
  # For the usb-to-parallel adapter connecting the printer.
  # TODO this does not seem to work...
  boot.kernelModules = [ "usblp" ];

  # load usblp dynamically, then:
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTR{idVendor}=="1a86", ATTR{idProduct}=="7584", RUN+="${pkgs.kmod}/bin/modprobe usblp"
  '';

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
  # TODO would be neat to pre-configure the bieb-gast network
  # see https://nixos.org/manual/nixos/stable/index.html#sec-wireless

  time.timeZone = "Europe/Amsterdam";

  users.users.deelnemer = {
    isNormalUser = true;
    extraGroups = [
      "networkmanager"
      "lp"
    ];
  };

  home-manager.users.deelnemer = {
    xdg.configFile."inkcut/inkcut.device.json".source = ./inkcut.device.json;
    xdg.configFile."inkcut/inkcut.job.json".source = ./inkcut.job.json;
  };

  environment.systemPackages = with pkgs; [
    firefox
    inkcut
    (inkscape-with-extensions.override {
      inkscapeExtensions = [
        inkscape-extensions.inkcut
      ];
    })
  ];
}
