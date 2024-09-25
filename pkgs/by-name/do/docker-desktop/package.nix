{
  stdenv,
  fetchurl,
  pkgs,
  lib,
  buildFHSEnv,
}: let
  pname = "docker-desktop";
  version = "4.34.0";
  revision = 165256;

  arch =
    {
      x86_64-linux = "amd64";
    }
    .${stdenv.hostPlatform.system};

  src = fetchurl {
    url = "https://desktop.docker.com/linux/main/${arch}/${toString revision}/${pname}-${arch}.deb?utm_source=nixpkgs";
    sha256 = "sha256-qFepUUftBj7GgM2ZIiY8GjhAy16RRPjg2oW1pgbSYYk=";
  };

  runtimeDependencies = pkgs:
    with pkgs; [
      libseccomp
      libcap_ng
      alsa-lib
      nss
      gtk3
      mesa
    ];

  package = stdenv.mkDerivation rec {
    inherit pname version revision src;

    nativeBuildInputs = with pkgs; [
      dpkg
      autoPatchelfHook
      makeWrapper
      pkg-config
    ];

    buildInputs = runtimeDependencies pkgs;

    sourceRoot = ".";
    unpackCmd = "${pkgs.dpkg}/bin/dpkg-deb -x $src .";

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin

      cp -R usr/{lib,share} opt $out/

      # Fix the path in the .desktop files.
      substituteInPlace \
        $out/share/applications/*.desktop \
        --replace-warn /opt/ $out/opt/

      # Fix the path in the .service file.
      substituteInPlace \
        $out/lib/systemd/user/${pname}.service \
        --replace-warn /opt/ $out/opt/

      # Symlink the binary to bin/.
      ln -s $out/opt/${pname}/Docker\ Desktop $out/bin/Docker\ Desktop

      runHook postInstall
    '';
  };
in
  buildFHSEnv {
    name = pname;
    targetPkgs = pkgs:
      (runtimeDependencies pkgs)
      ++ [package];

    runScript = "docker-desktop";
    extraInstallCommands = ''
      mkdir -p $out/share/applications

      ln -s ${package}/share/applications/* $out/share/applications
    '';

    meta = with lib; {
      description = "Docker Desktop is an easy-to-install application that enables you to locally build and share containerized applications and microservices.";
      homepage = "https://www.docker.com/products/docker-desktop";
      license = licenses.unfree;
      mainProgram = "docker-desktop";
      platforms = platforms.linux;
      maintainers = with maintainers; [BastianAsmussen];
    };
  }
