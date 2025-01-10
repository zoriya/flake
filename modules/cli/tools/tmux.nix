{pkgs, ...}: {
  home.packages = [
    (pkgs.writeShellScriptBin "tmux-sessionizer" (builtins.readFile ./tmux-sessionizer.sh))
  ];

  xdg.configFile."tmux/tmux.conf".text = ''
    unbind C-b
    set -g prefix C-t
    bind -N "Send the prefix key through to the application" t send-prefix

    set -g mouse on
    set -g status off
    set -g set-clipboard on
    set -g focus-events on

    set-window-option -g mode-keys vi
    bind-key v copy-mode
    bind-key -T copy-mode-vi i send -X cancel
    bind-key -T copy-mode-vi v send -X begin-selection
    bind-key -T copy-mode-vi V send -X select-line
    bind-key -T copy-mode-vi y send -X copy-selection -x
    bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-selection -x

    bind-key [ copy-mode \; send-keys -X previous-prompt
    bind-key ] copy-mode \; send-keys -X next-prompt
    bind-key -T copy-mode-vi [ send-keys -X previous-prompt
    bind-key -T copy-mode-vi ] send-keys -X next-prompt

    bind-key f run-shell "tmux neww tmux-sessionizer"
    bind-key C-h run-shell "tmux-sessionizer ~/projects/kyoo"
    bind-key C-s run-shell "tmux-sessionizer ~/projects/flake"
    bind-key C-n run-shell "tmux-sessionizer ~/projects/blog"

    run-shell ${pkgs.tmuxPlugins.sensible.rtp}
    run-shell ${pkgs.tmuxPlugins.fzf-tmux-url.rtp}

    # https://github.com/tmux/tmux/issues/4162
    set -gu default-command
    set -g default-shell "$SHELL"
  '';
}
