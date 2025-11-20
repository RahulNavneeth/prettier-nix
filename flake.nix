{
	description = "prettier nix";
	inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
	outputs = inputs@{ self, ... }: {
		flakeModule = ./flake-module.nix;
	};
}
