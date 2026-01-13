{ pkgs, ... }:

{
  # Context: Support for general Windows .exe programs (non-gaming)
  environment.systemPackages = with pkgs; [
    bottles
    winetricks
    wineWow64Packages.stable
  ];
}
