require 'color_logging'

module WarriorState
  include ColorLogging

  FULL_HEALTH = 20

  def self.included(base)
    base.on :turn_finish, :remember_health
  end

  def physical_state
    case
    when taking_damage?
      :taking_damage.tap { puts_danger "Taking damage" }
    when ! fit?
      :hurting.tap       { puts_warn   "Hurting: #{warrior.health}/#{FULL_HEALTH}" }
    else
      :ready_to_go.tap   { puts_success "Ready to go!" }
    end
  end

  def fit?
    warrior.health == FULL_HEALTH
  end

  def health_critical?
    warrior.health < FULL_HEALTH * 0.10
  end

  def taking_damage?
    warrior.health < @prev_health.to_i
  end

private

  def remember_health
    @prev_health = warrior.health
  end

end
