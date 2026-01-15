{
  config,
  lib,
  pkgs,
  ...
}:

{
  # --- LICENSE ACCEPTANCE (Add this line) ---
  nixpkgs.config.nvidia.acceptLicense = true;
  # ----------------------------------------

  # Disable Touchpad While Typing
  services.libinput = {
    enable = true;
    touchpad = {
      disableWhileTyping = true; # Explicitly prevent palm touches while typing
    };
  };

  # --- Input Device Management ---
  services.udev.extraRules = ''
    # Disable the Trackpoint (Nub)
    ACTION=="add|change", KERNEL=="event*", ATTRS{name}=="DualPoint Stick", ENV{LIBINPUT_IGNORE_DEVICE}="1"

    # Optional: Sometimes the stick also reports as a generic PS/2 mouse.
    # If the stick STILL works after adding the line above, uncomment the line below:
    # ACTION=="add|change", KERNEL=="event*", ATTRS{name}=="PS/2 Generic Mouse", ENV{LIBINPUT_IGNORE_DEVICE}="1"
  '';

  # --- Hardware Support ---
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # For 32-bit games
  };

  # --- NVIDIA Configuration ---
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have weird graphical corruption on resume.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # PROBABLY WON'T WORK on your Quadro M2200 (Maxwell).
    # Only works on newer Turing (RTX 20 series) and up.
    powerManagement.finegrained = false;

    # Do not use the open source kernel modules (only for Turing+).
    # Your M2200 must use the proprietary closed-source modules.
    open = false;

    # Enable the Nvidia settings menu (accessible via `nvidia-settings`).
    nvidiaSettings = true;

    # Select the production driver (usually the best bet).
    # If this fails, change it to `pkgs.linuxPackages.nvidiaPackages.legacy_470`
    # package = config.boot.kernelPackages.nvidiaPackages.production;

    # Changed from 'production' to 'legacy_470'.
    # This driver is the most stable version for the Quadro M2200.
    # package = config.boot.kernelPackages.nvidiaPackages.legacy_470;

    # Middle ground
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    # --- PRIME Offload Configuration ---
    # This allows you to use Intel for desktop and Nvidia for games.
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };

      # FIX ME: Put your Bus IDs here!
      # USE THIS COMMAND TO FIND YOUR BUS IDS: `nix run nixpkgs#pciutils -- -k | grep -EA2 'VGA|3D'`
      # Format is usually PCI:bus:device:function
      # If lspci says "00:02.0", that becomes "PCI:0:2:0"
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
      #
      # Reboot after building. To test if it works, run: `nvidia-smi`. If you see your GPU listed, you are golden.
    };
  };
}
