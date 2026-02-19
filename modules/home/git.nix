{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "0xr3x";
        email = "133902786+0xr3x@users.noreply.github.com";
      };

      gpg = {
        format = "ssh";
        ssh.program = "${pkgs._1password-gui}/bin/op-ssh-sign";
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
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKuxYP9adFjxLE3vCvSpuxtL/1uEz/f14/CL0ymqMxCW";
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
