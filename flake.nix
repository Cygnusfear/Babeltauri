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
          config.allowBroken = true;
        };
        rustToolchain = pkgs.rust-bin.stable.latest.default.override {
          extensions = [ "rust-src" "rust-analyzer" ];
        };

        # Platform-specific dependencies
        darwinDeps = with pkgs; lib.optionals stdenv.isDarwin [
          libiconv
        ];
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            rustToolchain
            cargo-watch
            bacon
            cargo-tauri
            just
            pkg-config
            openssl
            nodejs
            zlib
          ] ++ pkgs.lib.optionals pkgs.stdenv.isLinux [
            # Linux-specific dependencies
            gtk3
            webkitgtk_4_1
            libsoup_3
            glib
            glib-networking
          ] ++ darwinDeps;

          # Inherit the regular shell prompt
          NIX_SHELL_PRESERVE_PROMPT = true;

          shellHook = ''
            echo "🐠 Babelfish Tauri Dev Environment"
            echo "Run: cargo run"
            echo "Watch: cargo watch -x run"
            echo "Build: cargo tauri build"
            echo "Just: just --list"
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
              cargo-tauri
            ] ++ pkgs.lib.optionals pkgs.stdenv.isLinux [
              wrapGAppsHook3
            ];

            buildInputs = with pkgs; [
              openssl
            ] ++ pkgs.lib.optionals pkgs.stdenv.isLinux [
              glib
              gtk3
              webkitgtk_4_1
              libsoup_3
              glib-networking
            ] ++ darwinDeps;

            # Copy pre-built frontend before build
            preBuild = ''
              mkdir -p src-ui/dist
              cp -r ${frontend}/dist/* src-ui/dist/
            '';

            # Build with cargo tauri build (builds frontend + backend properly)
            buildPhase = ''
              runHook preBuild
              cargo tauri build
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
              platforms = platforms.linux ++ platforms.darwin;
            };
          };
      }
    );
}
