{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  imgui,
  freetype,
  hidapi,
}:
let
  udevRules = ''
    SUBSYSTEM=="usb", ATTRS{idVendor}=="3367", GROUP="plugdev", MODE="0660", TAG+="uaccess"
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3367", GROUP="plugdev", MODE="0660", TAG+="uaccess"
  '';
in
stdenv.mkDerivation (finalAttrs: {
  pname = "unofficial-egg-mouse-config";
  version = "0.3a";
  hash = "sha256-OmzgUsqOmrBhU8aWlyPUIiYbM9OJbTJRRIXqzQitvaE=";

  src = fetchFromGitHub {
    inherit (finalAttrs) hash;

    owner = "niansa";
    repo = "UnofficialEGGMouseConfig";
    rev = "v${finalAttrs.version}";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    imgui
    freetype
    hidapi
  ];

  installPhase = ''
    mkdir -p $out/{bin,etc/udev/rules.d}
    cp EGGMouseConfig $out/bin/EGGMouseConfig

    echo '${udevRules}' > $out/etc/udev/rules.d/30-egg.rules
  '';

  meta = {
    description = "Linux software to configure EGG XM2/OP1 8k mice";
    homepage = "https://github.com/niansa/UnofficialEGGMouseConfig";
    license = lib.licenses.unlicense;
    maintainers = with lib.maintainers; [ BastianAsmussen ];
    mainProgram = "EGGMouseConfig";
    platforms = lib.platforms.all;
  };
})
