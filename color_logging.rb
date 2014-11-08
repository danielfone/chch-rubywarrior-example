module ColorLogging
  ANSI_RED    = 31
  ANSI_GREEN  = 32
  ANSI_ORANGE = 33

  def puts_color(color_code, message)
    puts "\e[0;#{color_code}m#{message}\e[0m"
  end

  def puts_warn(message)
    puts_color ANSI_ORANGE, message
  end

  def puts_success(message)
    puts_color ANSI_GREEN, message
  end

  def puts_danger(message)
    puts_color ANSI_RED, message
  end

end