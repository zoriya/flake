# Flake

## To install

fdisk DEVICE

200M EFI fat32 labelled boot -> on /boot 

ext4 labbelled fuhen -> on /nix

mkdir -p /nix/persist/home (else persisted seems to be bugged)


`nix-shell --run 'mkpasswd -m SHA-512' -p mkpasswd` to generate a password
