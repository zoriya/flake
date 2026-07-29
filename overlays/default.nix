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
      }))
    // {
      jj-nvim = super.vimPlugins.jj-nvim.overrideAttrs (old: {
        version = "feat/browse";
        src = super.fetchFromGitHub {
          owner = "zoriya";
          repo = "jj.nvim";
          rev = "742cf28ce4c894782e7784e8f0a15c46121d7f50";
          hash = "sha256-HzTfZCbKYsM+FHd9tXkgWKfrj6LKwrqPUEGN3ik0nNI=";
        };
      });
    };

  discord = enableWayland super.discord ["discord" "Discord"];
  vesktop = enableWayland super.vesktop ["vesktop"];
  pear-desktop = enableWayland super.pear-desktop ["pear-desktop"];
  vscode = enableWayland super.vscode ["code"];

  claude-mux = super.buildGoModule {
    pname = "claude-mux";
    version = "0.1.0";
    src = ../claude-mux;
    vendorHash = "sha256-uwBJAqN4sIepiiJf9lCDumLqfKJEowQO2tOiSWD3Fig=";
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
