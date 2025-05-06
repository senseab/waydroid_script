{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      treefmt-nix,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
      inherit (pkgs) mkShell;
    in
    {
      formatter.${system} = treefmtEval.config.build.wrapper;
      devShell."${system}" = mkShell {
        nativeBuildInputs = with pkgs; [
          tokei
          nil
          (python3.withPackages (
            ps: with ps; [
              tqdm
              requests
              inquirerpy
            ]
          ))
        ];
      };

      packages."${system}" = rec {
        waydroid_script = pkgs.callPackage ./package.nix { };
        default = waydroid_script;
      };
    };
}
