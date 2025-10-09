{
  description = "Babelfish - Blazing fast TUI translator in Rust";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, rust-overlay }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };
        rustToolchain = pkgs.rust-bin.stable.latest.default.override {
          extensions = [ "rust-src" "rust-analyzer" ];
        };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            rustToolchain
            cargo-watch
            bacon
            cargo-tauri
            pkg-config
            openssl
            gtk3
            webkitgtk_4_1
            libsoup_3
            glib
            glib-networking
            nodejs
            zlib
          ];

          shellHook = ''
            echo "🐠 Babelfish Tauri Dev Environment"
            echo "Run: cargo run"
            echo "Watch: cargo watch -x run"
            echo "Build: cd src-ui && npm run build && cd .. && cargo build --release"
          '';
        };

        packages.default = pkgs.stdenv.mkDerivation rec {
          pname = "babelfish";
          version = "1.0.1";

          src = pkgs.fetchurl {
            url = "https://github.com/Cygnusfear/Babeltauri/releases/download/v${version}/babeltauri";
            sha256 = "1n7hixfyawny1zfc761iiixim47lj07cmhx8jiy6fy79qsmdyc0q";
          };

          dontUnpack = true;
          dontBuild = true;

          nativeBuildInputs = with pkgs; [
            autoPatchelfHook
          ];

          buildInputs = with pkgs; [
            openssl
            glib
            gtk3
            webkitgtk_4_1
            libsoup_3
            glib-networking
          ];

          installPhase = ''
            runHook preInstall
            mkdir -p $out/bin
            cp ${src} $out/bin/babelfish
            chmod +x $out/bin/babelfish
            runHook postInstall
          '';

          meta = with pkgs.lib; {
            description = "Blazing fast translator with Tauri UI";
            homepage = "https://github.com/Cygnusfear/Babeltauri";
            license = licenses.mit;
            maintainers = [ ];
            platforms = [ "aarch64-linux" ];
          };
        };
      }
    );
}
