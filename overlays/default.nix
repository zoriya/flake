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

  # gh only knows how to find a repo through git, which non-colocated jj repos hide.
  gh = wrapProgram super.gh ["gh"] ''
    --suffix PATH : ${super.lib.makeBinPath [super.jujutsu super.git super.coreutils]} \
    --run "source ${./gh-jj.sh}"'';

  # Orca renders plate thumbnails without making its gl context current. WebKit's dmabuf
  # renderer leaves its own context current, so orca draws into it and segfaults in mesa.
  orca-slicer = wrapProgram super.orca-slicer ["orca-slicer"] "--set WEBKIT_DISABLE_DMABUF_RENDERER 1";

  discord = enableWayland super.discord ["discord" "Discord"];
  vesktop = enableWayland super.vesktop ["vesktop"];
  pear-desktop = enableWayland super.pear-desktop ["pear-desktop"];
  vscode = enableWayland super.vscode ["code"];

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
