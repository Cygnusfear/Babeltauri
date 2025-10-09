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

        packages.default =
          let
            # Pre-build the frontend to avoid doing it during Rust build
            frontend = pkgs.buildNpmPackage {
              pname = "babelfish-frontend";
              version = "1.0.0";
              src = ./src-ui;

              npmDepsHash = "sha256-Wx+UIRrmi5oUW1TYTBPkmbB9DTCTug6x4R+ePsY0BKw=";

              buildPhase = ''
                npm run build
              '';

              installPhase = ''
                mkdir -p $out
                cp -r dist $out/
              '';
            };
          in
          pkgs.rustPlatform.buildRustPackage rec {
            pname = "babelfish";
            version = "1.0.0";
            src = ./.;

            cargoLock.lockFile = ./Cargo.lock;

            nativeBuildInputs = with pkgs; [
              pkg-config
              wrapGAppsHook3
            ];

            buildInputs = with pkgs; [
              openssl
              glib
              gtk3
              webkitgtk_4_1
              libsoup_3
              glib-networking
            ];

            # Copy pre-built frontend before build
            preBuild = ''
              mkdir -p src-ui/dist
              cp -r ${frontend}/dist/* src-ui/dist/
            '';

            # Build just the Rust binary, not the full Tauri bundle
            buildPhase = ''
              runHook preBuild
              cargo build --release
              runHook postBuild
            '';

            installPhase = ''
              runHook preInstall
              mkdir -p $out/bin
              cp target/release/babeltauri $out/bin/babelfish
              runHook postInstall
            '';

            meta = with pkgs.lib; {
              description = "Blazing fast translator with Tauri UI";
              homepage = "https://github.com/Cygnusfear/Babeltauri";
              license = licenses.mit;
              maintainers = [ ];
              platforms = platforms.linux;
            };
          };
      }
    );
}
