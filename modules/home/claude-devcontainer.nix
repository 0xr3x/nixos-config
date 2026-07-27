{ config, pkgs, ... }:

let
  repoPath = "${config.home.homeDirectory}/.claude-devcontainer";

  devcScript = pkgs.writeShellScriptBin "devc" ''
    if [ ! -d "${repoPath}" ]; then
      echo "Error: claude-code-devcontainer not found at ${repoPath}"
      echo "Run 'setup-claude-devcontainer' first."
      exit 1
    fi
    exec ${pkgs.bash}/bin/bash "${repoPath}/install.sh" "$@"
  '';
in
{
  home.packages = [
    devcScript
  ];

  programs.bash.initExtra = ''
    # Clone / update the Trail of Bits claude-code-devcontainer repo
    # and install @devcontainers/cli
    setup-claude-devcontainer() {
      if [ ! -d "${repoPath}" ]; then
        echo "Cloning claude-code-devcontainer..."
        git clone https://github.com/trailofbits/claude-code-devcontainer "${repoPath}"
      else
        echo "Updating claude-code-devcontainer..."
        git -C "${repoPath}" pull --ff-only
      fi

      if ! command -v devcontainer &>/dev/null; then
        echo "Installing @devcontainers/cli..."
        npm install --prefix ~/.local @devcontainers/cli
      fi

      echo "Done! Use 'devc' to manage devcontainers."
    }
  '';
}
