# Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # On the Lenovo Slim 5 (and certain other models), pressing Fn + F5/F6/etc 
  # may trigger a system shutdown when this module is active
  boot.blacklistedKernelModules = [ "ideapad_laptop" ];

  networking.hostName = "art"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "America/Sao_Paulo";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # NVIDIA setup
  hardware.graphics = {
    enable = true;
  };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {

    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead 
    # of just the bare essentials.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of 
    # supported GPUs is at: 
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    # Only available from driver 515.43.04+
    open = false;

    # Enable the Nvidia settings menu,
    nvidiaSettings = true;

  };

  hardware.nvidia.prime = {
      sync.enable = true;
 
      nvidiaBusId = "PCI:1:0:0";
      amdgpuBusId = "PCI:6:0:0";
  };

  # NVIDIA offload mode selection on bootloader
  specialisation = {
    on-the-go.configuration = {
      system.nixos.tags = [ "on-the-go" ];
      hardware.nvidia = {
        prime.offload.enable = lib.mkForce true;
        prime.offload.enableOffloadCmd = lib.mkForce true;
        prime.sync.enable = lib.mkForce false;
        };

      environment.sessionVariables = {
        AQ_DRM_DEVICES = "/dev/dri/card1";
      };
    };
  };

  # Define a user account.
  users.users.kaua = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ]; # Enable ‘sudo’ for the user.
  };

  # Globally allow unfree packages
  nixpkgs.config = {
    allowUnfree = true;
  };

  # Hyprland
  programs.hyprland.enable = true;

  # Better Electron/Wayland compatibility
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Neovim
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git
    stow
    wget
    unzip
    mpv
    wine
    kitty
    fuzzel
    mako
    waybar
    yazi
    zathura
    brightnessctl
    syncthing
    obsidian
    brave
    stremio
    discord
  ];

  # Default fonts
  fonts = {
    enableDefaultPackages = true;

    packages = with pkgs; [
      fira-code-nerdfont
      noto-fonts-emoji
      libertinus
    ];

    fontconfig = {

      defaultFonts = {
        serif = [ "Libertinus Serif" ];
        sansSerif = [ "Libertinus Sans" ];
        monospace = [ "FiraCode Nerd Font Mono" ];
	emoji = [ "Noto Color Emoji" ];
        };
      };
    };


  # Default applications
  xdg.mime.defaultApplications = {
   "text/html" = "brave-browser.desktop";
   "x-scheme-handler/http" = "brave-browser.desktop";
   "x-scheme-handler/https" = "brave-browser.desktop";
   "x-scheme-handler/unknown" = "brave-browser.desktop";
   "application/pdf" = "org.pwmt.zathura.desktop";
   "video/mp4" = "mpv.desktop";
   "video/x-matroska" = "mpv.desktop";
   "video/webm" = "mpv.desktop";
   "video/x-msvideo" = "mpv.desktop";
   "video/x-ms-wmv" = "mpv.desktop";
   "audio/mpeg" = "mpv.desktop";
   "audio/x-wav" = "mpv.desktop";
   "audio/x-flac" = "mpv.desktop";
   "audio/ogg" = "mpv.desktop";
   "audio/mp4" = "mpv.desktop";
   "audio/webm" = "mpv.desktop";
   "application/ogg" = "mpv.desktop";
  };

 
  # Allow experimental features (like the nix search command)
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Automatic updates
  system.autoUpgrade.enable = true;
  system.autoUpgrade.dates = "weekly";

  # Automatic cleanup
  nix.gc.automatic = true;
  nix.gc.dates = "daily";
  nix.gc.options = "--delete-older-than 10d";
  nix.optimise.automatic = true;
  nix.optimise.dates = [ "3:45" ];

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.11"; # Did you read the comment?

}

