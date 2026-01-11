{
  description = "Nixos config for King";

  inputs = {
    # Default: Stable branch (tested, reliable, less frequent updates)
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

    # Unstable branch (latest packages, more frequent updates)
    # Use this for specific packages that need to be bleeding edge
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      ...
    }@inputs:
    let
      # Create pkgs-unstable from the unstable branch
      pkgs-unstable = import nixpkgs-unstable {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
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
            inherit pkgs-unstable; # Pass unstable packages to modules
          };
          modules = [
            ./hosts/default/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit pkgs-unstable; };
              home-manager.users.king = import ./hosts/default/home.nix;
              # "If you find a file blocking you, rename it to .backup and keep going."
              home-manager.backupFileExtension = "backup";
            }
          ];
        };
      };
    };
}
