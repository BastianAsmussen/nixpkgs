{
  lib,
  stdenv,
  fetchurl,
  openjdk,
  runtimeShell,
}:
stdenv.mkDerivation rec {
  pname = "leo3";
  version = "1.2";

  src = fetchurl {
    url = "https://github.com/leoprover/Leo-III/releases/download/v${version}/leo3.jar";
    sha256 = "1lgwxbr1rnk72rnvc8raq5i1q71ckhn998pwd9xk6zf27wlzijk7";
  };

  dontUnpack = true;

  installPhase = ''
    mkdir -p "$out"/{bin,lib/java/leo3}
    cp "${src}" "$out/lib/java/leo3/leo3.jar"
    echo "#!${runtimeShell}" > "$out/bin/leo3"
    echo "'${openjdk}/bin/java' -jar '$out/lib/java/leo3/leo3.jar' \"\$@\""  >> "$out/bin/leo3"
    chmod a+x "$out/bin/leo3"
  '';

  meta = with lib; {
    description = "Automated theorem prover for classical higher-order logic with choice";
    mainProgram = "leo3";
    sourceProvenance = with sourceTypes; [ binaryBytecode ];
    license = licenses.bsd3;
    maintainers = [ maintainers.raskin ];
    platforms = platforms.linux;
    homepage = "https://page.mi.fu-berlin.de/lex/leo3/";
  };
}
