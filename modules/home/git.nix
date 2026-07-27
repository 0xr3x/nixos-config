{ config, pkgs, ... }:

let
  gitEmail = "133902786+0xr3x@users.noreply.github.com";

  # Public half of the signing key; the private half lives in 1Password
  # ("Wonderland Github SSH Key") and is only ever reachable via its SSH agent.
  signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKuxYP9adFjxLE3vCvSpuxtL/1uEz/f14/CL0ymqMxCW";

  allowedSignersFile = "${config.xdg.configHome}/git/allowed_signers";
in
{
  # Trust our own key so `git log --show-signature` and `git verify-commit` can
  # verify local commits. Without this git signs fine but refuses to verify,
  # failing with "gpg.ssh.allowedSignersFile needs to be configured and exist".
  # The principal must match the commit's committer email, not a display name.
  xdg.configFile."git/allowed_signers".text = "${gitEmail} ${signingKey}\n";

  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "0xr3x";
        email = gitEmail;
      };

      gpg = {
        format = "ssh";
        ssh.program = "${pkgs._1password-gui}/bin/op-ssh-sign";
        ssh.allowedSignersFile = allowedSignersFile;
      };

      commit = {
        gpgsign = true;
      };

      init = {
        defaultBranch = "main";
      };

      pull = {
        rebase = true;
      };

      push = {
        autoSetupRemote = true;
      };

      diff = {
        algorithm = "histogram";
      };
    };

    signing = {
      key = signingKey;
      signByDefault = true;
    };

    settings.alias = {
      co = "checkout";
      br = "branch";
      st = "status -sb";
      cm = "commit -m";
      lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
    };
  };
}
