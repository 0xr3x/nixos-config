{ config, pkgs, ... }:

{
  # Environment variables
  home.sessionVariables = {
    NH_FLAKE = "/etc/nixos";
    SSH_AUTH_SOCK = "$HOME/.1password/agent.sock";
  };

  # Bash configuration
  programs.bash = {
    enable = true;
    initExtra = "umask 077";
    
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
    };
  };

  # dbt helper functions (dbt Fusion CLI comes from the dbt-fusion overlay in
  # flake.nix — a Nix-managed global binary, not a per-project uv/pip venv)
  home.file.".local/bin/dbt-new".source = pkgs.writeShellScript "dbt-new" ''
    set -e

    project_name="''${1:?Usage: dbt-new <project-name>}"
    project_path="$HOME/Documents/dbt/$project_name"

    if [ -d "$project_path" ]; then
      echo "❌ Project already exists at $project_path"
      exit 1
    fi

    mkdir -p "$project_path"
    cd "$project_path"

    echo "📦 Creating dbt project: $project_name"

    # Create basic dbt_project.yml
    mkdir -p models tests
    cat > dbt_project.yml << DBT_EOF
name: "''${project_name}"
version: '1.0.0'
config-version: 2

profile: "''${project_name}"

model-paths: ["models"]
analysis-paths: ["analysis"]
test-paths: ["tests"]
data-paths: ["data"]
macro-paths: ["macros"]
snapshot-paths: ["snapshots"]
target-path: "target"
clean-targets:
  - "target"
  - "dbt_packages"

models:
  ''${project_name}:
    +materialized: view
DBT_EOF

    # Register a duckdb profile, without clobbering existing entries
    mkdir -p "$HOME/.dbt" 2>/dev/null || true
    touch "$HOME/.dbt/profiles.yml"
    if ! grep -q "^''${project_name}:" "$HOME/.dbt/profiles.yml"; then
      cat >> "$HOME/.dbt/profiles.yml" << PROFILES_EOF

''${project_name}:
  outputs:
    dev:
      type: duckdb
      path: ./''${project_name}.duckdb
      threads: 4
  target: dev
PROFILES_EOF
    fi

    # Initialize git
    git init
    cat > .gitignore << 'GITIGNORE_EOF'
target/
dbt_packages/
*.duckdb
*.duckdb-wal
logs/
GITIGNORE_EOF
    git add .
    git commit -m "Initial dbt project setup"

    echo ""
    echo "✅ Project created at $project_path"
    echo ""
    echo "Quick start:"
    echo "  cd $project_path"
    echo "  dbt build"
    echo ""
  '';

  # Clone sample project helper
  home.file.".local/bin/dbt-clone-sample".source = pkgs.writeShellScript "dbt-clone-sample" ''
    set -e

    project_path="$HOME/Documents/dbt/jaffle_shop"

    if [ -d "$project_path" ]; then
      echo "❌ jaffle_shop already exists at $project_path"
      cd "$project_path"
      exit 0
    fi

    mkdir -p "$project_path"
    cd "$project_path"

    echo "📥 Cloning jaffle_shop sample project..."
    git clone https://github.com/dbt-labs/jaffle_shop.git . --depth 1

    echo ""
    echo "✅ jaffle_shop cloned to $project_path"
    echo ""
    echo "Quick start:"
    echo "  cd $project_path"
    echo "  dbt build"
    echo "  dbt compile --write-catalog  # generates catalog.json (docs generate/serve are deprecated in Fusion)"
    echo ""
  '';

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
