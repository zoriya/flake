# Flake

![screenshot](./screen.png)
![screenshot](./screen2.png)

## Tools

- WM: river + luatile
- Widgets: ags (+ astal for river integration) + rofi (app picker + clipboard history picker)
- Lockscreen: hyprlock (+ hypridle for loginctl/auto suspend when locked)
- Lots of cli tools
- Impermanence (everything except `~/stuff` & `~/projects` is wiped on reboot), `/` is a tmpfs.

## Nvim

 - Is configured through lua
 - Plugins & LSP are configured in nix
 - Everything is binary compiled at build time
 - Everything is packed in a single plugin to optimize the runtimepath length
 - A `.luarc.json` can be generated using `nix develop`
 - The config can be used from anywhere using `nix run github:zoriya/flake#nvim`


## Notes for myself

`mkdir -p /nix/persist/home` (else persisted seems to be bugged)
`nix-shell --run 'mkpasswd -m SHA-512' -p mkpasswd` to generate a password
`NIX_CONFIG="extra-access-tokens = github.com=$(gh auth token)" nix flake update`
