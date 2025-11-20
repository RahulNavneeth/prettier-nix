{ lib, self, flake-parts-lib, ... }:
let
	inherit (lib) mkOption mkEnableOption;
in
{
    options = {
    	perSystem = flake-parts-lib.mkPerSystemOption ({ config, pkgs, ... }:
		let
    		cfg = config.prettier;
    		prettierBin = "${pkgs.nodePackages.prettier}/bin/prettier";
    		writeIgnore =
    		    if cfg.exclude == []
    		    then null
    		    else pkgs.writeText ".prettierignore" (lib.concatStringsSep "\n" cfg.exclude);
    		ignoreArg = lib.optionalString (writeIgnore != null) "--ignore-path ${writeIgnore}";
    		includeArgs = lib.concatStringsSep " " cfg.include;
    		extraArgs = lib.concatStringsSep " " cfg.extraArgs;
		in {
			options.prettier = {
    			enable = mkEnableOption "Enable Prettier integration";
    			root = mkOption {
    			    type = lib.types.str;
    			    default = ".";
    			};
    			include = mkOption {
    			    type = lib.types.listOf lib.types.str;
    			    default = [ "**/*.js" "**/*.ts" "**/*.tsx" "**/*.json" "**/*.md" ];
    			};
    			exclude = mkOption {
    			    type = lib.types.listOf lib.types.str;
    			    default = [ "node_modules/**" "dist/**" "build/**" ];
    			};
    			extraArgs = mkOption {
    			    type = lib.types.listOf lib.types.str;
    			    default = [];
    			};
				formatter = mkOption {
				    type = lib.types.package;
				    # default = pkgs.runCommand "prettier-formatter-empty" {} "mkdir -p $out";
					readOnly = true;
				};
				checks = mkOption {
				    type = lib.types.package;
				    # default = pkgs.runCommand "prettier-check-empty" {} "mkdir -p $out";
					readOnly = true;
				};
				devShells = mkOption {
				    type = lib.types.package;
				    # default = pkgs.runCommand "prettier-devshell-empty" {} "mkdir -p $out";
					readOnly = true;
				};
			};
			config = lib.mkIf cfg.enable {
                prettier.formatter =
                    pkgs.writeShellScriptBin "prettier-format" ''
                        cd ${cfg.root}
                        exec ${prettierBin} ${includeArgs} ${ignoreArg} ${extraArgs} --write
                    '';
                prettier.checks =
                    pkgs.runCommand "prettier-check" { buildInputs = [ pkgs.nodePackages.prettier ]; } ''
                        cd ${cfg.root}
                        ${prettierBin} --check ${includeArgs} ${ignoreArg} ${extraArgs}
                        touch $out
                    '';
                prettier.devShells = pkgs.mkShell {
                    packages = [ pkgs.nodePackages.prettier ];
                };
            };
        });
    };
}
