module ColorLogging
  ANSI_RED    = 31
  ANSI_GREEN  = 32
  ANSI_ORANGE = 33

  def puts_color(color_code, message)
    puts "\e[0;#{color_code}m" << message << "\e[0m"
  end

end