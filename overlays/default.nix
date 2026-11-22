{...}: self: super: let
  wrapProgram = drv: bins: wrapProgramFlags:
    super.symlinkJoin {
      name = drv.name;
      paths = [drv];
      meta = drv.meta or {};
      passthru = drv.passthru or {};
      buildInputs = [super.makeWrapper];
      postBuild = super.lib.concatStrings (map (bin: ''
          wrapProgram $out/bin/${bin} \
            ${wrapProgramFlags}
        '')
        bins);
    };
  enableWayland = drv: bins:
    wrapProgram drv bins ''
      --add-flags "--enable-features=UseOzonePlatform" \
      --add-flags "--ozone-platform=wayland" \
      --add-flags "--disable-smooth-scrolling"'';
in {
  # they try to use passthrough if they detect tmux. we don't want that.
  osc = wrapProgram super.osc ["osc"] ''
    --set TMUX ""
  '';

  # Gnome-control-center can only be launched if XDG_CURRENT_DESKTOP is GNOME.
  gnome-control-center = wrapProgram super.gnome-control-center ["gnome-control-center"] "--set XDG_CURRENT_DESKTOP GNOME";

  # Some nvim plugins ship without a license, so nixpkgs marks them unfree.
  vimPlugins =
    super.vimPlugins
    // super.lib.genAttrs [
      "unclash-nvim"
      "vim-wordmotion"
    ] (name:
      super.vimPlugins.${name}.overrideAttrs (old: {
        meta = old.meta // {license = super.lib.licenses.mit;};
      }));

  # The machine we sshed from remote-forwards its open-url socket to this port
  # (see modules/gui/home.nix), so links land in the browser we are sitting in
  # front of instead of on the box we are sshed into. Nothing listens on it when
  # we are not sshed anywhere, and we then open locally.
  open-url = super.writeShellScriptBin "open-url" ''
    if (printf '%s\n' "$1" >/dev/tcp/127.0.0.1/17321) 2>/dev/null; then
      exit 0
    fi
    exec ${
      if super.stdenv.hostPlatform.isDarwin
      then "/usr/bin/open"
      else super.lib.getExe' super.xdg-utils "xdg-open"
    } "$1"
  '';

  # gh only knows how to find a repo through git, which non-colocated jj repos hide.
  gh = wrapProgram super.gh ["gh"] ''
    --suffix PATH : ${super.lib.makeBinPath [super.jujutsu super.git super.coreutils]} \
    --set-default GH_BROWSER ${super.lib.getExe self.open-url} \
    --run "source ${./gh-jj.sh}"'';

  # Orca renders plate thumbnails without making its gl context current. WebKit's dmabuf
  # renderer leaves its own context current, so orca draws into it and segfaults in mesa.
  orca-slicer = wrapProgram super.orca-slicer ["orca-slicer"] "--set WEBKIT_DISABLE_DMABUF_RENDERER 1";

  vesktop = enableWayland super.vesktop ["vesktop"];
  pear-desktop = enableWayland super.pear-desktop ["pear-desktop"];

  # https://github.com/NixOS/nixpkgs/pull/585097
  browse = let
    version = "0.0.16";
    targets = {
      x86_64-linux = {
        target = "linux-x64";
        hash = "sha512-l/adQHsk8y49F/a2Wm6yUYZKrD578zojSLyd/iXQ1pLee0eZFWiW27KI6NbBB7CTWuDKRZEyb+zstZs0Z4pqzg==";
      };
      aarch64-linux = {
        target = "linux-arm64";
        hash = "sha512-kqt9LGOEwYbL6We4yyIevCGaLJNulClV6RxOvYaMjANUIyyBIlTtDOPQECiuTfyo/MQ8eMWIbCioOyssksigYw==";
      };
      aarch64-darwin = {
        target = "darwin-arm64";
        hash = "sha512-H6HihYDLzZqk/SlrNOwNh5Aht4huceIxP4e+fWq7l9n2zkJ52kUW/EnCVQjBwJg2fvTJShxouDAPCST0+O/KWA==";
      };
    };
    t = targets.${super.stdenv.hostPlatform.system};
  in
    super.stdenvNoCC.mkDerivation {
      pname = "browse";
      inherit version;
      src = super.fetchurl {
        url = "https://registry.npmjs.org/@opencode/browse-${t.target}/-/browse-${t.target}-${version}.tgz";
        inherit (t) hash;
      };
      nativeBuildInputs = [super.makeWrapper] ++ super.lib.optionals super.stdenv.hostPlatform.isLinux [super.autoPatchelfHook];
      buildInputs = super.lib.optionals super.stdenv.hostPlatform.isLinux [(super.lib.getLib super.stdenv.cc.cc)];
      # bun keeps the bundled js inside the executable.
      dontStrip = true;
      installPhase = ''
        install -Dm755 bin/browse $out/bin/browse
        # It would rerun its install script to replace itself.
        wrapProgram $out/bin/browse --set OPENCODE_BROWSER_AUTO_UPDATE off
      '';
      meta = {
        description = "Let your AI agents use your real browser";
        homepage = "https://github.com/anomalyco/browse";
        license = super.lib.licenses.mit;
        platforms = builtins.attrNames targets;
        mainProgram = "browse";
      };
    };

  # https://github.com/NixOS/nixpkgs/pull/587729
  kotlin-lsp = let
    version = "271.2085.0";
    targets = {
      x86_64-linux = {
        file = "kotlin-server-${version}.tar.gz";
        hash = "sha256-45jnmQJ/QXSeoz+qV0cDB9E9QPkQlhhYx+MK29d4rgg=";
      };
      aarch64-linux = {
        file = "kotlin-server-${version}-aarch64.tar.gz";
        hash = "sha256-h3ruYSoX2rSBREZigqZBTsWKtCihC5fH4T7dm2s9yW4=";
      };
      x86_64-darwin = {
        file = "kotlin-server-${version}.sit";
        hash = "sha256-aEV6sYJTMePqyFGRt8MnN8vYmThn9anFDf4BLFUJ6Pc=";
      };
      aarch64-darwin = {
        file = "kotlin-server-${version}-aarch64.sit";
        hash = "sha256-LSI4j1i+b036eo8YweIxhxFk3KzBbkB1WQKdcjKBa0o=";
      };
    };
    t = targets.${super.stdenv.hostPlatform.system};
  in
    super.stdenv.mkDerivation {
      pname = "kotlin-lsp";
      inherit version;
      src = super.fetchurl {
        url = "https://download.jetbrains.com/language-server/kotlin-server/${version}/${t.file}";
        inherit (t) hash;
      };
      # the mac archives are zips with a .sit extension
      unpackCmd = super.lib.optionalString super.stdenv.hostPlatform.isDarwin "unzip -q $curSrc";
      nativeBuildInputs =
        [super.makeWrapper]
        ++ super.lib.optionals super.stdenv.hostPlatform.isLinux [super.autoPatchelfHook]
        ++ super.lib.optionals super.stdenv.hostPlatform.isDarwin [super.unzip];
      buildInputs = super.lib.optionals super.stdenv.hostPlatform.isLinux [(super.lib.getLib super.stdenv.cc.cc) super.zlib];
      # The bundled jbr runs headless, its awt/sound libs are never loaded.
      autoPatchelfIgnoreMissingDeps = true;
      dontStrip = true;
      dontFixup = super.stdenv.hostPlatform.isDarwin;
      installPhase = ''
        mkdir -p $out/lib $out/bin
        cp -r . $out/lib/kotlin-lsp
        makeWrapper $out/lib/kotlin-lsp/bin/intellij-server $out/bin/kotlin-lsp
      '';
      meta = {
        description = "Kotlin language server by JetBrains";
        homepage = "https://github.com/Kotlin/kotlin-lsp";
        license = super.lib.licenses.unfree;
        platforms = builtins.attrNames targets;
        mainProgram = "kotlin-lsp";
      };
    };

  claude-mux = super.buildGoModule {
    pname = "claude-mux";
    version = "0.1.0";
    src = ../claude-mux;
    vendorHash = "sha256-TUbaUoqDZoQTkcOMtoE/FlAiqkWN+x49JeGkDguh2UU=";
    nativeBuildInputs = [super.makeWrapper];
    postInstall = ''
      wrapProgram $out/bin/claude-mux \
        --prefix PATH : ${super.lib.makeBinPath [super.tmux]}
    '';
    meta = {
      description = "tmux-backed session manager for Claude Code";
      mainProgram = "claude-mux";
    };
  };
}
