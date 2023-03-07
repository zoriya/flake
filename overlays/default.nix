self: super: {
  adi1090x-plymouth = super.callPackage ./adi1090x-plymouth.nix {};
  tuxedo-keyboard = super.callPackage ./tuxedo-keyboard {};
}
