{ lib, stdenv, fetchurl, autoPatchelfHook }:

let
  version = "2.1.34";
  
  sources = {
    x86_64-linux = {
      url = "https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/${version}/linux-x64/claude";
      hash = "sha256-NmXxL2ehFZsxAF3M4Ryh3kHUl1m649Ae2FOUD+fEoh8=";
    };
    aarch64-linux = {
      url = "https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/${version}/linux-arm64/claude";
      hash = "sha256-/7BiWtYJtYFs7fsjj4gl9itkN0erfP5aU/NS/U7Xezs=";
    };
  };
  
  source = sources.${stdenv.hostPlatform.system} or (throw "Unsupported system");
  
in stdenv.mkDerivation {
  pname = "claude-code";
  inherit version;
  
  src = fetchurl {
    inherit (source) url hash;
  };
  
  dontUnpack = true;
  
  nativeBuildInputs = [ autoPatchelfHook ];
  
  installPhase = ''
    install -Dm755 $src $out/bin/claude
  '';
  
  meta = with lib; {
    description = "Claude Code - AI coding assistant";
    homepage = "https://claude.ai";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" "aarch64-linux" ];
  };
}
