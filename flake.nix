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
            echo "Build: cargo build --release"
          '';
        };

        packages.default = pkgs.rustPlatform.buildRustPackage {
          pname = "babelfish";
          version = "0.1.0";
          src = ./.;
          cargoLock.lockFile = ./Cargo.lock;
          nativeBuildInputs = [ pkgs.pkg-config ];
          buildInputs = [ pkgs.openssl ];
        };
      }
    );
}
