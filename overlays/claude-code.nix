{ writeShellScriptBin, nodejs_22 }:

writeShellScriptBin "claude-code" ''
  exec ${nodejs_22}/bin/npx -y @anthropic-ai/claude-code "$@"
''
