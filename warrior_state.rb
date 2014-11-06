module WarriorState

  FULL_HEALTH = 20

  def current_state
    case
    when taking_damage?
      :taking_damage.tap { puts_color(ANSI_RED, "Taking damage") }
    when safe? && ! fit?
      :safe_hurting.tap { puts_color(ANSI_ORANGE, "Hurting: #{health}/#{FULL_HEALTH}") }
    else
      :ready_to_go.tap { puts_color(ANSI_GREEN, "Ready to go!") }
    end
  end

  def fit?
    health == FULL_HEALTH
  end

  def health_critical?
    health < FULL_HEALTH*0.40
  end

  def safe?
    ! taking_damage?
  end

  def taking_damage?
    health < @prev_health
  end

end
