{pkgs, ...}: let
  niri-workspaces = pkgs.writeShellApplication {
    name = "niri-workspaces";
    runtimeInputs = [pkgs.niri pkgs.jq];
    text = ''
      # kanshi execs us while the outputs are still moving, so wait for them to settle
      prev=""
      for _ in $(seq 25); do
        cur=$(niri msg -j outputs | jq -r '[.[] | select(.logical) | .name] | sort | join(" ")')
        if [ -n "$cur" ] && [ "$cur" = "$prev" ]; then break; fi
        prev="$cur"
        sleep 0.2
      done

      outs=$(niri msg -j outputs | jq -c '[.[] | select(.logical)]')
      # the dell while the dock is plugged in, the laptop panel otherwise
      main=$(jq -rn --argjson o "$outs" '($o | map(select(.model == "DELL S2722QC")) + map(select(.name == "eDP-1")) + $o)[0].name // ""')
      second=$(jq -rn --argjson o "$outs" --arg m "$main" '[$o[] | select(.name != $m)][0].name // ""')
      [ -n "$main" ] || exit 0
      was=$(niri msg -j workspaces | jq '[.[] | select(.is_focused)][0].id // 0')

      if [ -n "$second" ]; then
        # niri deletes any empty workspace that is neither named nor the last one, so naming
        # the trailing empty one is the only way to keep slot 1 of the main screen free.
        # index references resolve against the focused monitor, hence the focus-monitor
        if [ "$(niri msg -j workspaces | jq '[.[] | select(.name == "scratch")] | length')" -eq 0 ]; then
          niri msg action focus-monitor "$main"
          niri msg action set-workspace-name scratch \
            --workspace "$(niri msg -j workspaces | jq --arg m "$main" '[.[] | select(.output == $m)] | length')"
        fi
        targets="$second:1:music $main:1:scratch $main:2:chat $main:3:work"
      else
        # a single screen, so what the second one would carry takes slot 1 and the
        # placeholder goes away -- unless something is parked on it, then it just drifts down
        scratch=$(niri msg -j workspaces | jq '[.[] | select(.name == "scratch")][0].id // 0')
        if [ "$(niri msg -j windows | jq --argjson s "$scratch" '[.[] | select(.workspace_id == $s)] | length')" -eq 0 ]; then
          niri msg action unset-workspace-name scratch
        fi
        targets="$main:1:music $main:2:chat $main:3:work"
      fi

      for t in $targets; do
        out=''${t%%:*}
        idx=''${t#*:}
        ws=''${idx#*:}
        idx=''${idx%%:*}
        # leaving the ones already in place alone is what keeps a rebuild, which execs us
        # with nothing to do, from animating the whole layout around
        if [ "$(niri msg -j workspaces | jq -r --arg n "$ws" '.[] | select(.name == $n) | "\(.output) \(.idx)"')" = "$out $idx" ]; then
          continue
        fi
        niri msg action move-workspace-to-monitor "$out" --reference "$ws"
        niri msg action move-workspace-to-index "$idx" --reference "$ws"
      done

      # and hand the focus back if the shuffling dragged it along. only if it moved, mind:
      # workspace-auto-back-and-forth turns a focus request for the workspace you are already
      # on into a jump to the previous one
      now=$(niri msg -j workspaces | jq '[.[] | select(.is_focused)][0].id // 0')
      back=$(niri msg -j workspaces | jq -r --argjson w "$was" '.[] | select(.id == $w) | "\(.output) \(.idx)"')
      if [ "$now" -ne "$was" ] && [ -n "$back" ]; then
        niri msg action focus-monitor "''${back% *}"
        niri msg action focus-workspace "''${back#* }"
      fi
    '';
  };
in {
  imports = [
    ../../modules/gui/home.nix
    ../../modules/wm/home.nix
  ];
  services.gnome-keyring.enable = true;

  home.packages = with pkgs; [
    pamixer
    brightnessctl
    playerctl
    hyprpicker
    wtype

    gnome-control-center
    gnome-weather
    wdisplays
  ];

  wayland.windowManager.niri = {
    enable = true;
    systemd.enable = true;
    extraConfig = builtins.readFile ./niri.kdl;
  };

  xdg.configFile."systemd/user/niri.service.d/unset-shlvl.conf".text = ''
    [Service]
    UnsetEnvironment=SHLVL
  '';

  services.kanshi = {
    enable = true;
    systemdTarget = "graphical-session.target";
    settings = [
      {
        output.criteria = "eDP-1";
        output.scale = 1.6;
      }
      {
        profile.name = "undocked";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "enable";
          }
        ];
        profile.exec = ["${niri-workspaces}/bin/niri-workspaces"];
      }
      {
        profile.name = "docked";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "disable";
          }
          {
            criteria = "Dell Inc. DELL S2722QC 2HHZH24";
            # position = "1500,0";
            position = "0,900";
            scale = 1.7;
          }
          {
            criteria = "*";
            position = "0,0";
            scale = 1.4;
          }
        ];
        profile.exec = ["${niri-workspaces}/bin/niri-workspaces"];
      }
    ];
  };
}
