{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.34";
  
  sources = {
    x86_64-linux = {
      url = "https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/${version}/linux-x64/claude";
      sha256 = "3665f12f67a1159b31005dcce11ca1de41d49759bae3d01ed853940fe7c4a21f";
    };
    aarch64-linux = {
      url = "https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/${version}/linux-arm64/claude";
      sha256 = "ffb0625ad609b5816cedfb23f88325f62b63747ab6fdfe5a53f352fd4ed77b33";
    };
  };
  
  source = sources.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
  
in stdenv.mkDerivation {
  pname = "claude-code";
  inherit version;
  
  src = fetchurl {
    inherit (source) url sha256;
  };
  
  dontUnpack = true;
  dontBuild = true;
  
  nativeBuildInputs = lib.optionals stdenv.isLinux [
    autoPatchelfHook
  ];
  
  installPhase = ''
    runHook preInstall
    
    install -Dm755 $src $out/bin/claude
    
    runHook postInstall
  '';
  
  meta = with lib; {
    description = "Claude Code - AI coding assistant by Anthropic";
    homepage = "https://claude.ai";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    maintainers = [ ];
    mainProgram = "claude";
  };
}
