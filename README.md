# Flake

![screenshot](./screen.png)
![screenshot](./screen2.png)

## Tools

- WM: river + luatile
- Widgets: ags (+ astal for river integration) + rofi (app picker + clipboard history picker)
- Lockscreen: hyprlock (+ hypridle for loginctl/auto suspend when locked)
- Lots of cli tools


## Notes

`mkdir -p /nix/persist/home` (else persisted seems to be bugged)


`nix-shell --run 'mkpasswd -m SHA-512' -p mkpasswd` to generate a password
