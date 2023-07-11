{
  enable = true;
  extraConfig = ''
    local wezterm = require 'wezterm'

    -- wezterm.gui is not available to the mux server, so take care to
    -- do something reasonable when this config is evaluated by the mux
    function get_appearance()
      if wezterm.gui then
        return wezterm.gui.get_appearance()
      end
      return 'Dark'
    end

    function scheme_for_appearance(appearance)
      if appearance:find 'Light' then
        return 'Gruvbox Light'
      else
        return 'GruvboxDark'
      end
    end

    config = {}

    config.font = wezterm.font_with_fallback { 'JetBrains Mono', 'Font Awesome 6 Free' }
    config.hide_tab_bar_if_only_one_tab = true
    config.color_scheme = scheme_for_appearance(get_appearance())
    config.window_background_opacity = 0.9;
    config.window_padding = { left = 1, right = 1, top = 1, bottom = 1 }

    return config
  '';
}
