{
  description = "Nixos config for King";

  inputs = {
    # Default: unstable branch (latest packages, more frequent updates)
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Stable branch (tested, more stable, less frequent updates)
    # Update version when a new stable release is available
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-stable,
      home-manager,
      ...
    }@inputs:
    let
      # Create pkgs-stable from the stable branch
      pkgs-stable = nixpkgs-stable.legacyPackages.x86_64-linux;
    in
    {
      nixosConfigurations = {
        # Configuration name: "nixos"
        # This is what you reference with `--flake ./nixos#nixos`
        # You can create other configurations here (e.g., "nixos-laptop", "nixos-server")
        # by adding more entries to this set
        nixos = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit pkgs-stable; # Pass stable packages to modules
          };
          modules = [
            ./hosts/default/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.king = import ./hosts/default/home.nix;
              # "If you find a file blocking you, rename it to .backup and keep going."
              home-manager.backupFileExtension = "backup";
            }
          ];
        };
      };
    };
}
