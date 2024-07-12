# Flake

![screenshot](./screen.png)


## Notes

`mkdir -p /nix/persist/home` (else persisted seems to be bugged)


`nix-shell --run 'mkpasswd -m SHA-512' -p mkpasswd` to generate a password
