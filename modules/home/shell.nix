{ config, pkgs, ... }:

{
  # Environment variables
  home.sessionVariables = {
    NH_FLAKE = "/etc/nixos";
  };

  # Bash configuration
  programs.bash = {
    enable = true;
    shellAliases = {
      ll = "ls -lah";
      ls = "eza";
      cat = "bat";
      grep = "rg";
      find = "fd";
      top = "btop";
      rebuild = "nh os switch";
      update = "nh os switch --update";
      cleanup = "nh clean all --keep 5";
      bat-check = "acpi -b";
      bright = "brightnessctl";
      cd = "z";  # use zoxide
      
      # Sandboxed Cursor (recommended)
      cursor = "cursor-safe";
      
      # Unsandboxed Cursor (use with caution)
      cursor-unsafe = "code-cursor-fhs";
    };
    
    # Claude Code function (not alias) for better flexibility
    initExtra = ''
      claude() {
        # If no arguments, show help
        if [ $# -eq 0 ]; then
          echo "Usage: claude <command> [args]"
          echo ""
          echo "Claude Code runs in an isolated container with current directory mounted."
          echo ""
          echo "Examples:"
          echo "  claude chat 'explain this code'"
          echo "  claude /status"
          echo "  claude --help"
          return 0
        fi
        
        # Run claude in container with current directory mounted
        podman run --rm -it \
          -v "$PWD:/workspace:Z" \
          -w /workspace \
          ghcr.io/anthropics/claude-code:latest \
          "$@"
      }
    '';
  };

  # Better shell prompt
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    settings = {
      add_newline = false;
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };
      directory = {
        truncation_length = 3;
        truncate_to_repo = true;
      };
    };
  };

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    defaultCommand = "fd --type f";  # use fd instead of find
  };

  # Auto-load project environments
  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };

  # Smart directory jumping
  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
  };

  # Better manpages
  programs.man = {
    enable = true;
    generateCaches = true;
  };
}
