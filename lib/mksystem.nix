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
  customHome ? [],
}: let
  systemFunc =
    if darwin
    then inputs.nix-darwin.lib.darwinSystem
    else nixpkgs.lib.nixosSystem;
  home-manager =
    if darwin
    then inputs.home-manager.darwinModules
    else inputs.home-manager.nixosModules;

  cli =
    if darwin
    then ../modules/cli/darwin.nix
    else ../modules/cli;

  specialArgs = inputs // {inherit user;};
in
  systemFunc {
    inherit system specialArgs;
    modules =
      [
        overlays
        cli
        (../environments + "/${env}")

        ({pkgs, ...}: {
          networking.hostName = hostname;

          users.users.${user} = {
            home =
              if darwin
              then "/Users/${user}"
              else "/home/${user}";
            shell = pkgs.zsh;

            openssh.authorizedKeys.keys = [
              "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDGcLP/ZEjnSgkzQMBeLLOWn5uejSr9Gg1h9PJZECVTLm+VDQ7KyI3ORZt+qbfEnsnGL73iwcAqB5Upy9Cdj0182mnrTk2ZViNMeFT7kLBF0yXpiajQTtMjENYj0nbNWpQ5+sJrtJKKYK/tBghW8PyTrJPpVQcrLcf4D66U5DkkJNRDeu4v9SjHKaASUeyia4gRSVV59Ugtrl0lz8sl4yBSL4957zwzdkNR0pVmftaKmUP4KfBvpNcFOOpHcdvzDtEPQs8j0g2l65YOQNNFSMsYQfxt1X4zmEi4unRIlECglaPz12CyoTiM2xmCWa/mS5nm0dR1VbEHFMRtGbbgm9MwedXoxYAfycbu08fqi1AAvg7MQxDNLfWWBIHe7+imGLKrVkqk8B89I409iI4YiOytnUkxKZkxynqVYtEE0bx5J15mniq2vJTw9JD89qSVkvGjZNGuJgh4leIlxPGj4iP8KY3N3Ifaf72PsmmwW4rB5JPDW93RL1DZV8lk3NgyF8M= zoriya@fuhen" # laptop
              "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCpQ8Td98YIS0EtVQ7xabYVe9A9/+ZECrHBpKi01NKQ0Mleg9Z4fnTsdGFX1uhbG6Pu7niBVzYReVTC1CbyVWKmm/4DbbRpaqY94eOzQEe0p4wMSURQ9weuB5737k+5MuLDLUbhc1ytDa84Ubj/A/rQUueKdq2K1o+YSN7b7HKe7kXoXACEpbrSCC43mteBgCtvgsLY0New9xXnvGFJPSe7PcjYkOhSJB1xA0Gu4DoDdOyErvV62QQH4sSQMu5cFICJGfdXQzBdshA8MgWKXFv3Hq7K5/GGDNyCsMxeoPQET3vbmgUsE+KGtcdqizdFM3bAfCBGXOBx6h7BoNuQzkp8hgmrq62CmMwF0krX05Sb3qR/wVjRKDo9pYuSk6/awnnBp5kY6sNgEruI93ZXNQWMkxXQNbmpCi+uEvzMveP16O/uP3NxklD4wtmfpSZsxBi+jRGFqcjdy3Qlc13Tiz98EBaXkir9YwUAh8SNs3gRaJGI0Fn2HzUCPH0zNh42EY8= zoriya@kadan" # server
              "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDGoTI403QZIO8E+mrZu0Jw+Tu+xzSfgdyBMLIFLHiJMheBr+GAxnycQJC7W1O/dHe3esih1DPB/dtF3HJgIKWx9cVSOacgNSVN3xz2wEnrkJY8tP+GmL4WaieHL3qK9eu8Qx3zhMjA/tDyFwG0gbIqkm5T3mh5KtEBLvPiqJsavAh24Oyo3/hoQkZp6QW+iei+wbRIHp+CkEjeUQPXvMRemOHc2VjUyY72+NXzbufZYH5xpnqAzTgn/kT1b1y5ipd+QVKnG7LEJt2Kd7mDZ7e/Dgi4VMBkJ9JaAmxLl+SrdZ1dSOrCojfyRc83nBkEYaIsoYtSQTHFQn4utDI8rsUFwkTLR1+tR9PXIz5dFd5kWUpHAM273XsMCTVqq9Dm2XToK3uguVlXVmv9X87f8PHFwdWX8x5FnB3qaOxpQefI+PWkZybDqp6NRwsSJZ5JJn5dOUNrkZnLlgl6zVbuuFneN1oBZE5X+pZayFRBtDP5G1B1gU3qbIAyo83vPAzUFUM= u0_a369@localhost" # android
              "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDJ/c2rQ9xUI6XpDR/+dmCK5IcxkOIezvNtbC2EVTrfh73H5juotME6JrQSxgQjtgsaUAzZzrac9kI/7Do8/lisbofdKRcneXi2UEeERKrKEwC/EGcQgqnoPLL1+mnqwvQ923d3105DV4hFksoDbblCinFuUr5s55EMm991IL/T70cy820AOgAf+hgleM1Its47EBkZBzpa4KwxYepJG0+kBa7K1Loi9QgBvTGpxs7rWMDxllfL6ivrWJxAKRZdWlJ/MKBVQIYhv0W+vaQ7OZA1qUY4bq/9wY/i88nixbVSPJmikj0+QNeLksU78bOIxLpTTeLdH4HQ6+qKOBT3JhEpBtUHdBxOT5tYJTr4qwjevlFqceLw3x1V9URxPS2XBDjlxnzYzdnD40LK5BehXdmElGio9dy98/qJINbDW/7AH+BpP1GWNKVhiYXPj7A/2fkFD2K7DgIgGlsrZthS+LxDTEcQ8Yx0iD/+nI8LcnvU42S0muSvmP7LE4xBl8AoaI0= zoriya@nixos" # lucca windows
              "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC0lycSIHU5JVcA7M3ChDJliER5MDoaqxWCGX8LeGwklQVwKcUY3y4gO0pD8DRHWrgQv44qP4owxOX7/ulHPjQehzPOU+as3qRH0e76EFutwN6tNvE56PNvwsAFiPVoz4ykDqZNwl8IXO9rk2JQuw+UOAvI7Lq0citaBwHzYaw+eO7qHi9iQHYZLsxgu6SzaOxbp7gmppZ//6PHD7ypxqiRORqW/xlt3N70va4zORdk6M4hMoFZCh33PYUiua01iLMxiBvDGC0pzMtmvRkSlmvZv30zdO/B9l/bBrjhtcAz2l/fabFG6gAlTeprzvv36kItKy2taxcBuQr6NxhtvLW6zF422/MibMsqSIb2KsMdO15DAVm3lMFMQDVUY+7t5rssvV5MVU05Tnnw5cKLTzVC6fVnPlBVJPfnYwPGRyJVZgp4Q7uAdVmitCL/+zxHDbAw5AmRgV4WJ86h5lRRzH41KtncC57Ilbe6BUbIwQF7oowJs67TttF6L7HwQx9b+ns= zroux@zroux-mac" # lucca macos
            ];
          };
        })
        ../hosts/${hostname}/hardware-configuration.nix

        home-manager.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = specialArgs;
            users.${user} = {
              imports =
                [
                  ../modules/cli/home.nix
                  (../environments + "/${env}/home.nix")
                ]
                ++ customHome;
            };
          };
        }
      ]
      ++ nixpkgs.lib.optionals (!darwin)
      [
        inputs.nix-index-database.nixosModules.nix-index
        {
          users.users.root.hashedPassword = builtins.readFile ../password/root;
          users.users.${user} = {
            isNormalUser = true;
            hashedPassword = builtins.readFile ../password/${user};
            extraGroups = ["wheel" "input" "docker" "audio" "mlocate" "libvirtd"];
          };
          networking.nameservers = ["1.1.1.1" "9.9.9.9"];
          networking.resolvconf.extraConfig = "name_servers=\"1.1.1.1 9.9.9.9\"";
        }
      ]
      ++ nixpkgs.lib.optionals wsl [
        inputs.nixos-wsl.nixosModules.wsl
        ({pkgs, ...}: {
          wsl.enable = true;
          wsl.defaultUser = user;
          environment.systemPackages = with pkgs; [
            wslu
            wsl-open
          ];

          services.flatpak.enable = true;
          xdg.portal = {
            enable = true;
            wlr.enable = true;
            config.common.default = "*";
          };
        })
      ]
      ++ nixpkgs.lib.optionals darwin [
        inputs.nix-index-database.darwinModules.nix-index
      ]
      ++ custom;
  }
