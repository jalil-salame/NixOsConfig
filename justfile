default: check

# Check flake syntax
check:
    nix flake check

# Update flake
update: && check
    nix flake update

# Format nix files
fmt:
    nix fmt

# Build OS configuration
os action='test': fmt
    sudo nixos-rebuild {{action}} --flake .#
