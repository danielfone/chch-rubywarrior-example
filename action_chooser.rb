require 'warrior_state'
require 'warrior_context'

module ActionChooser

  def self.included(base)
    base.public_send :include, WarriorState
    base.public_send :include, WarriorContext

    base.on :turn_start, *[
      :assess_required_health,
      :assess_fitness,
    ]
  end

  def best_action
    case physical_state
    when :taking_damage then taking_damage_action
    when :hurting       then hurting_action
    when :ready_to_go   then ready_to_go_action
    end
  end

private

  def taking_damage_action
    if engaged?
      health_critical? ? retreat! : :attack!
    else
      hurting_action
    end
  end

  def hurting_action
    case
    when needs_health? && safe?
      :rest!
    when needs_health? && !safe?
      @target_health += 3 if next_unit_name == 'Archer' # dat arrow
      retreat!
    else
      ready_to_go_action
    end
  end

  def ready_to_go_action
    # Deal with captives
    return [:rescue!, :backward] if next_to_captive? :backward
    return [:walk!,   :backward] if next_unit_name(:backward) == 'Captive'
    return :rescue! if next_to_captive?
    return :walk!   if next_unit_name == 'Captive'

    # Deal with enemies
    return :attack! if engaged?
    return :shoot!  if clear_shot_on_wizard?
    return :walk!   if enemy_visible?
    return :pivot!  if enemy_visible? :backward

    # navigate
    return :pivot!       if blocked?
    return go_to_stairs! if range_clear?
    return :walk!
  end

  def go_to_stairs!
    [:walk!, stairs_direction]
  end

  def retreat!
    [:walk!, :backward]
  end

  def needs_health?
    !! @target_health
  end

  def assess_fitness
    # Clear our health target if we've met it
    @target_health = nil if warrior.health >= @target_health
  end

  def assess_required_health
    # If we've already got a health target, don't update
    @target_health ||= required_health
  end

  def required_health
    case next_spaces
    when / S./
      13
    when / aa/
      11
    when /  a/
      9
    when / a./
      6
    when / s./
      7
    else
      0
    end
  end

end
