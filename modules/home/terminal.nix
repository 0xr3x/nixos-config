{ config, pkgs, ... }:

{
  # Kitty terminal
  programs.kitty = {
    enable = true;
    font = {
      name = "JetBrains Mono";
      size = 11;
    };
    settings = {
      # Performance
      repaint_delay = 10;
      input_delay = 3;
      sync_to_monitor = "yes";
      
      # Appearance
      background_opacity = "0.95";
      window_padding_width = 8;
      confirm_os_window_close = 0;
      
      # Cursor
      cursor_shape = "beam";
      cursor_blink_interval = 0;
      
      # URLs
      url_color = "#0087bd";
      url_style = "curly";
      open_url_with = "default";
      
      # Scrollback
      scrollback_lines = 10000;
      
      # Mouse
      copy_on_select = "yes";
      strip_trailing_spaces = "smart";
      
      # Tab bar
      tab_bar_style = "powerline";
      tab_powerline_style = "slanted";
      
      # Bell
      enable_audio_bell = "no";
      visual_bell_duration = 0;
      
      # Theme (Catppuccin Mocha)
      foreground = "#CDD6F4";
      background = "#1E1E2E";
      selection_foreground = "#1E1E2E";
      selection_background = "#F5E0DC";
      
      # Black
      color0 = "#45475A";
      color8 = "#585B70";
      
      # Red
      color1 = "#F38BA8";
      color9 = "#F38BA8";
      
      # Green
      color2 = "#A6E3A1";
      color10 = "#A6E3A1";
      
      # Yellow
      color3 = "#F9E2AF";
      color11 = "#F9E2AF";
      
      # Blue
      color4 = "#89B4FA";
      color12 = "#89B4FA";
      
      # Magenta
      color5 = "#F5C2E7";
      color13 = "#F5C2E7";
      
      # Cyan
      color6 = "#94E2D5";
      color14 = "#94E2D5";
      
      # White
      color7 = "#BAC2DE";
      color15 = "#A6ADC8";
    };
    keybindings = {
      # Tab management
      "ctrl+shift+t" = "new_tab";
      "ctrl+shift+w" = "close_tab";
      "ctrl+shift+right" = "next_tab";
      "ctrl+shift+left" = "previous_tab";
      
      # Font size
      "ctrl+shift+equal" = "change_font_size all +1.0";
      "ctrl+shift+minus" = "change_font_size all -1.0";
      "ctrl+shift+0" = "change_font_size all 0";
      
      # Clipboard
      "ctrl+shift+c" = "copy_to_clipboard";
      "ctrl+shift+v" = "paste_from_clipboard";
    };
  };
}
