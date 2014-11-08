module WarriorState
  FULL_HEALTH = 20

  def self.included(base)
    base.on :game_start, :initialize_health
    base.on :turn_finish, :remember_health
  end

  def physical_state
    case
    when taking_damage?
      :taking_damage.tap { puts_color(ANSI_RED, "Taking damage") }
    when ! fit?
      :hurting.tap { puts_color(ANSI_ORANGE, "Hurting: #{health}/#{FULL_HEALTH}") }
    else
      :ready_to_go.tap { puts_color(ANSI_GREEN, "Ready to go!") }
    end
  end

  def fit?
    health == FULL_HEALTH
  end

  def health_critical?
    health < FULL_HEALTH*0.10
  end

  def taking_damage?
    health < prev_health
  end

private

  def prev_health
    @prev_health
  end

  def initialize_health(warrior)
    @prev_health = 0
  end

  def remember_health
    @prev_health = health
  end

end
