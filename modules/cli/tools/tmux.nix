{pkgs, ...}: {
  home.packages = [
    (pkgs.writeShellScriptBin "tmux-sessionizer" (builtins.readFile ./tmux-sessionizer.sh))
  ];

  programs.tmux = {
    enable = true;
    terminal = "tmux-256color";

    mouse = true;
    focusEvents = true;
    aggressiveResize = true;
    clock24 = true;

    historyLimit = 50000;
    # default is 500 which makes vim's esc slow, we do not want 0 because it won't be able to read osc
    escapeTime = 50;

    keyMode = "vi";
    prefix = "C-t";

    plugins = with pkgs.tmuxPlugins; [fzf-tmux-url];

    extraConfig =
      #tmux
      ''
        set -g status off
        set -s set-clipboard on

        # from tmux-sensible
        set -g display-time 4000
        set -g status-interval 5

        bind-key v copy-mode
        bind-key -T copy-mode-vi i send -X cancel
        bind-key -T copy-mode-vi v send -X begin-selection
        bind-key -T copy-mode-vi V send -X select-line
        bind-key -T copy-mode-vi y send -X copy-selection -x
        bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-selection -x
        bind-key -T copy-mode-vi p { refresh-client -l; run -d0.05; paste-buffer; send -X cancel }

        bind-key [ copy-mode \; send-keys -X previous-prompt
        bind-key ] copy-mode \; send-keys -X next-prompt
        bind-key -T copy-mode-vi [ send-keys -X previous-prompt
        bind-key -T copy-mode-vi ] send-keys -X next-prompt

        bind-key f run-shell "tmux neww tmux-sessionizer"
        bind-key C-h run-shell "tmux-sessionizer ~/projects/kyoo"
        bind-key C-s run-shell "tmux-sessionizer ~/projects/flake"
        bind-key C-n run-shell "tmux-sessionizer ~/projects/blog"

        # suspend inner tmux (to allow nested sessions)
        bind -T root @ { set prefix None; set key-table off }
        bind -T off C-@ { set -u prefix; set -u key-table }
      '';
  };
}
