{ config, pkgs, ... }:

let
  # Path to the dev-env repository
  devEnvRepo = "${config.home.homeDirectory}/dev-env";
  
  # Create the devenv wrapper script
  devenvScript = pkgs.writeShellScriptBin "devenv" ''
    # Check if dev-env repo exists
    if [ ! -d "${devEnvRepo}" ]; then
      echo "Error: dev-env repository not found at ${devEnvRepo}"
      echo "Clone it first: git clone git@github.com:defi-wonderland/dev-env.git ${devEnvRepo}"
      exit 1
    fi
    
    # Run the Makefile with all arguments passed through
    exec make -f "${devEnvRepo}/Makefile" -- "$@"
  '';
in
{
  # Install required tools for dev-env
  home.packages = with pkgs; [
    docker-compose
    nodejs_22  # for npm
    gnumake
    devenvScript
  ];
  
  # Add bash aliases and functions for dev-env
  programs.bash.shellAliases = {
    # Quick access to dev-env commands
    dev = "devenv shell";
    dev-status = "devenv status";
    dev-ps = "devenv ps";
  };
  
  programs.bash.initExtra = ''
    # Dev-env API key management
    devenv-add-key() {
      local repo_path="${devEnvRepo}"
      
      if [ ! -d "$repo_path" ]; then
        echo "Error: dev-env not set up yet. Run 'setup-devenv' first."
        return 1
      fi
      
      cd "$repo_path" || return 1
      
      if [ ! -f .env ]; then
        echo "Error: .env file not found. Run 'setup-devenv' first."
        return 1
      fi
      
      echo "Add API Keys to dev-env"
      echo "======================="
      echo ""
      echo "Current keys (encrypted):"
      if [ -f .env.keys ]; then
        ~/.local/node_modules/.bin/dotenvx get OPENROUTER_API_KEY >/dev/null 2>&1 && echo "✅ OPENROUTER_API_KEY: Set" || echo "❌ OPENROUTER_API_KEY: Empty"
        ~/.local/node_modules/.bin/dotenvx get CLAUDE_CODE_OAUTH_TOKEN >/dev/null 2>&1 && echo "✅ CLAUDE_CODE_OAUTH_TOKEN: Set" || echo "❌ CLAUDE_CODE_OAUTH_TOKEN: Empty"
      else
        echo "⚠️  No encrypted keys yet"
      fi
      echo ""
      echo "To generate Claude OAuth token:"
      echo "  1. Inside devenv shell, run: claude"
      echo "  2. Complete OAuth flow in browser"
      echo "  3. Find token in ~/.claude/config.json"
      echo "  4. Add it here"
      echo ""
      
      # Prompt for keys
      read -p "Enter OpenRouter API key (or press Enter to skip): " openrouter_key
      read -p "Enter Claude Code OAuth token (or press Enter to skip): " claude_token
      
      # Update .env file
      if [ -n "$openrouter_key" ]; then
        ~/.local/node_modules/.bin/dotenvx set OPENROUTER_API_KEY "$openrouter_key"
        echo "✅ Updated OPENROUTER_API_KEY"
      fi
      
      if [ -n "$claude_token" ]; then
        ~/.local/node_modules/.bin/dotenvx set CLAUDE_CODE_OAUTH_TOKEN "$claude_token"
        echo "✅ Updated CLAUDE_CODE_OAUTH_TOKEN"
      fi
      
      if [ -n "$openrouter_key" ] || [ -n "$claude_token" ]; then
        echo ""
        echo "⚠️  IMPORTANT: Keep .env.keys safe! It's your decryption key."
        echo "    Never commit .env.keys to git."
      else
        echo "No keys provided. Skipped."
      fi
    }
    
    # Dev-env setup helper
    setup-devenv() {
      local repo_path="${devEnvRepo}"
      
      if [ ! -d "$repo_path" ]; then
        echo "Cloning dev-env repository..."
        mkdir -p "$(dirname "$repo_path")"
        git clone git@github.com:defi-wonderland/dev-env.git "$repo_path"
      fi
      
      cd "$repo_path" || return 1
      
      # Check prerequisites
      echo "Checking prerequisites..."
      command -v docker >/dev/null 2>&1 || { echo "Error: docker not found"; return 1; }
      command -v npm >/dev/null 2>&1 || { echo "Error: npm not found"; return 1; }
      command -v gh >/dev/null 2>&1 || { echo "Error: gh not found"; return 1; }
      
      # Check GitHub authentication
      if ! gh auth status >/dev/null 2>&1; then
        echo "GitHub CLI not authenticated. Please run:"
        echo "  gh auth login --web -p https"
        return 1
      fi
      
      # Create .env file if it doesn't exist
      if [ ! -f .env ]; then
        echo "Creating .env file..."
        local git_name=$(git config --get user.name)
        local git_email=$(git config --get user.email)
        local user_uid=$(id -u)
        local user_gid=$(id -g)
        local timezone=$(cat /etc/timezone 2>/dev/null || echo "UTC")
        
        cat > .env <<EOF
USERNAME=developer
USER_UID=$user_uid
USER_GID=$user_gid
TIMEZONE=$timezone
GIT_DEFAULT_NAME=$git_name
GIT_DEFAULT_EMAIL=$git_email
OPENROUTER_API_KEY=
ANTHROPIC_API_KEY=
CLAUDE_CODE_OAUTH_TOKEN=
EOF
        echo "✅ Created .env file"
      fi
      
      # Install dotenvx locally (nixpkgs version is broken)
      if ! command -v dotenvx >/dev/null 2>&1; then
        echo "Installing dotenvx to ~/.local/bin..."
        # npm --prefix installs to prefix/node_modules/.bin/
        npm install --prefix ~/.local @dotenvx/dotenvx
        # Ensure it's in PATH
        export PATH="$HOME/.local/node_modules/.bin:$HOME/.local/bin:$PATH"
      fi
      
      # Encrypt .env if not already encrypted
      if [ ! -f .env.keys ]; then
        echo "Encrypting .env file..."
        ~/.local/node_modules/.bin/dotenvx encrypt || dotenvx encrypt
        echo "⚠️  IMPORTANT: Keep .env.keys safe! It's your decryption key."
      fi
      
      echo ""
      echo "✅ dev-env setup complete!"
      echo ""
      echo "Quick start:"
      echo "  cd ~/your-project"
      echo "  devenv shell          # Start development environment"
      echo "  devenv shell --3000   # With port 3000 exposed"
      echo "  devenv status         # Check container status"
      echo ""
    }
  '';
  
  # Session variables
  home.sessionVariables = {
    # Ensure Docker works rootless
    DOCKER_HOST = "unix://$XDG_RUNTIME_DIR/podman/podman.sock";
  };
}
