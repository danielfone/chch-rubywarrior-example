module ActionChooser

  def self.included(base)
    base.on :turn_start, *[
      :assess_fitness,
      :assess_required_health,
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
    case
    when engaged? && health_critical?
      retreat!
    when engaged?
      :attack!
    else
      hurting_action
    end
  end

  def hurting_action
    case
    when @target_health && safe?
      :rest!
    when @target_health && !safe?
      @target_health += 3 # accounts for archers
      retreat!
    else
      ready_to_go_action
    end
  end

  def ready_to_go_action
    # Deal with captives
    return [:pivot!, @captive_direction]  if @captive_direction
    return :rescue! if near_captive?
    return :walk! if next_unit_name == 'Captive'

    # Deal with enemies
    return :attack! if engaged?
    return :shoot!  if clear_shot_on_wizard?
    return :walk!   if enemy_in_range?
    return [:pivot!, @archer_direction]   if @archer_direction
    return [:pivot!, @enemy_direction]  if @enemy_direction


    # navigate
    return [:pivot!, :backward]  if blocked?
    return [:pivot!, @stairs_direction] if @stairs_direction
    go_to_stairs if range_clear?
    return :walk!
  end

  def go_to_stairs
    return [:pivot!, @stairs_direction] if @stairs_direction
    return :walk!
  end

  def retreat!
    [:walk!, :backward]
  end

  def assess_fitness
    if @target_health && health >= @target_health
      @target_health = nil
      puts_color ANSI_GREEN, "Fighting fit"
    end
  end

  def assess_required_health
    return if @target_health # We've already got a target, don't update
    if health < required_health
      @target_health = required_health
      puts_color ANSI_RED, "Need rest!"
    end
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
