{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    # Core IaC tools
    terraform
    ansible

    # Version control
    git

    # Security and CI/CD tools
    trufflehog
    act

    # Utilities
    apacheHttpd # for htpasswd
  ];

  shellHook = ''
    echo "Entering development environment for Blithe-1..."
    echo "Key tools available: terraform, ansible, git, act, trufflehog, htpasswd"
  '';
}
