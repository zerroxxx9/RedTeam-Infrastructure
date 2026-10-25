{
  description = "GoPhish engagement box — Terraform IaC dev shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            terraform
            hcloud
            jq
          ];

          shellHook = ''
            export CHECKPOINT_DISABLE=1   # no HashiCorp telemetry / upgrade pings
            echo "IaC dev shell ready — terraform + hcloud CLI."
            echo "Auth: export HCLOUD_TOKEN=...  (used by both terraform and the hcloud CLI),"
            echo "      or put tokens in terraform.tfvars (gitignored)."
          '';
        };
      });
}
