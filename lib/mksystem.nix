{
  nixpkgs,
  overlays,
  ...
} @ inputs: hostname: {
  env,
  user ? "zoriya",
  system ? "x86_64-linux",
  wsl ? false,
  darwin ? false,
  custom ? [],
}: let
  systemFunc =
    if darwin
    then inputs.darwin.lib.darwinSystem
    else nixpkgs.lib.nixosSystem;
  home-manager =
    if darwin
    then inputs.home-manager.darwinModules
    else inputs.home-manager.nixosModules;

  cli =
    if darwin
    then ../modules/cli/darwin.nix
    else ../modules/cli;
in
  systemFunc {
    inherit system;
    specialArgs = inputs;
    modules =
      [
        overlays
        inputs.impermanence.nixosModules.impermanence
        cli
        (../environments + "/${env}")

        ({pkgs, ...}: {
          networking.hostName = hostname;
          users.users.root.hashedPassword = builtins.readFile ../password/root;

          users.users.${user} = {
            home =
              if darwin
              then "/Users/${user}"
              else "/home/${user}";
            hashedPassword = builtins.readFile ../password/${user};
            isNormalUser = true;
            extraGroups = ["wheel" "input" "docker" "audio" "mlocate" "libvirtd"];
            shell = pkgs.zsh;

            openssh.authorizedKeys.keys = [
              "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDGcLP/ZEjnSgkzQMBeLLOWn5uejSr9Gg1h9PJZECVTLm+VDQ7KyI3ORZt+qbfEnsnGL73iwcAqB5Upy9Cdj0182mnrTk2ZViNMeFT7kLBF0yXpiajQTtMjENYj0nbNWpQ5+sJrtJKKYK/tBghW8PyTrJPpVQcrLcf4D66U5DkkJNRDeu4v9SjHKaASUeyia4gRSVV59Ugtrl0lz8sl4yBSL4957zwzdkNR0pVmftaKmUP4KfBvpNcFOOpHcdvzDtEPQs8j0g2l65YOQNNFSMsYQfxt1X4zmEi4unRIlECglaPz12CyoTiM2xmCWa/mS5nm0dR1VbEHFMRtGbbgm9MwedXoxYAfycbu08fqi1AAvg7MQxDNLfWWBIHe7+imGLKrVkqk8B89I409iI4YiOytnUkxKZkxynqVYtEE0bx5J15mniq2vJTw9JD89qSVkvGjZNGuJgh4leIlxPGj4iP8KY3N3Ifaf72PsmmwW4rB5JPDW93RL1DZV8lk3NgyF8M= zoriya@fuhen" # laptop
              "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCpQ8Td98YIS0EtVQ7xabYVe9A9/+ZECrHBpKi01NKQ0Mleg9Z4fnTsdGFX1uhbG6Pu7niBVzYReVTC1CbyVWKmm/4DbbRpaqY94eOzQEe0p4wMSURQ9weuB5737k+5MuLDLUbhc1ytDa84Ubj/A/rQUueKdq2K1o+YSN7b7HKe7kXoXACEpbrSCC43mteBgCtvgsLY0New9xXnvGFJPSe7PcjYkOhSJB1xA0Gu4DoDdOyErvV62QQH4sSQMu5cFICJGfdXQzBdshA8MgWKXFv3Hq7K5/GGDNyCsMxeoPQET3vbmgUsE+KGtcdqizdFM3bAfCBGXOBx6h7BoNuQzkp8hgmrq62CmMwF0krX05Sb3qR/wVjRKDo9pYuSk6/awnnBp5kY6sNgEruI93ZXNQWMkxXQNbmpCi+uEvzMveP16O/uP3NxklD4wtmfpSZsxBi+jRGFqcjdy3Qlc13Tiz98EBaXkir9YwUAh8SNs3gRaJGI0Fn2HzUCPH0zNh42EY8= zoriya@kadan" # server
              "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCnPn6ga4tsJfdyGyft9RnJJmSvlGLn/rJuLsWwFHtxHwdcOolZEAn2zrLqOo1Fty44lrWJ62KLOJ+eZVt4rfREBWd+esttTY2BbhrjvRThKsst1RJdWjFXI3xny7v48mMG8PKjTCkXom2Y/wfLKRpeaNJyCgauUNdDFXuiwiMmIEGXN/WE6LfWBg2XbPWilMLEVm6pwXf3lGtaS0QxhIQ/OIdx5XfUKS6lUfRq9Ki6FbsSQ60ejRtKmjbqY93KNQPUBAJnJHgDDX2+pkrSKiNHBjFH5/HZJTSRdpumaqO0E+HZRSEbR/aKRvshUN0SO/59pvrqb1ARF6CG2X0k0A+jTag0N7SyLwHEJ8J/bl43zm0JWenfAPMuhzQqAv3Vw4i13u8mgHf+ng7ClDo1ms5K7e/XXZV7Asb6orkuslZCO2QR3WgfmbUU03r89aG7Eg58ZeGMP57CoEcMAVah20to4iPm5HPy/Ej0JznFXXjRW4z+/DZDvWhFtsjIkalqQCU= u0_a369@localhost" # android
              "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDJ/c2rQ9xUI6XpDR/+dmCK5IcxkOIezvNtbC2EVTrfh73H5juotME6JrQSxgQjtgsaUAzZzrac9kI/7Do8/lisbofdKRcneXi2UEeERKrKEwC/EGcQgqnoPLL1+mnqwvQ923d3105DV4hFksoDbblCinFuUr5s55EMm991IL/T70cy820AOgAf+hgleM1Its47EBkZBzpa4KwxYepJG0+kBa7K1Loi9QgBvTGpxs7rWMDxllfL6ivrWJxAKRZdWlJ/MKBVQIYhv0W+vaQ7OZA1qUY4bq/9wY/i88nixbVSPJmikj0+QNeLksU78bOIxLpTTeLdH4HQ6+qKOBT3JhEpBtUHdBxOT5tYJTr4qwjevlFqceLw3x1V9URxPS2XBDjlxnzYzdnD40LK5BehXdmElGio9dy98/qJINbDW/7AH+BpP1GWNKVhiYXPj7A/2fkFD2K7DgIgGlsrZthS+LxDTEcQ8Yx0iD/+nI8LcnvU42S0muSvmP7LE4xBl8AoaI0= zoriya@nixos" # lucca windows
            ];
          };
        })
        ../hosts/${hostname}/hardware-configuration.nix

        home-manager.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = inputs;
            users.${user} = {
              imports = [
                ../modules/cli/home.nix
                (../environments + "/${env}/home.nix")
                inputs.nix-index-database.hmModules.nix-index
              ];
            };
          };
        }
      ]
      ++ custom;
  }
