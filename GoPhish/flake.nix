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
          # Terraform is BSL-licensed, so nixpkgs marks it unfree. This flag lets
          # the devShell include it. To avoid unfree entirely, drop this line and
          # swap `terraform` -> `opentofu` below (then use `tofu` instead of
          # `terraform` on the CLI — it reads the same .tf files unchanged).
          config.allowUnfree = true;
        };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            terraform   # or: opentofu
            hcloud      # Hetzner CLI — handy for checking which server types are in stock
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
