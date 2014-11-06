module WarriorContext

  def required_health
    case next_unit_name
    when "Sludge"
      6+1
    when "Thick Sludge"
      12+1
    when "Archer"
      5+1
    else
      0
    end
  end

  def next_unit_name
    next_unit_space = look.find { |s| s.unit }
    next_unit_space.unit.name if next_unit_space
  end

  def clear_shot_on_wizard?
    next_unit_name == 'Wizard'
  end

  def engaged?(direction=:forward)
    feel(direction).enemy?
  end

  def near_captive?
    feel.captive?
  end

  def blocked?
    feel.wall?
  end

  def enemy_in_range?(direction=:forward)
    look(direction).any? &:enemy?
  end

  def captive_in_range?(direction=:forward)
    look(direction).any? &:captive?
  end

  def stairs_in_range?(direction=:forward)
    look(direction).any? &:stairs?
  end

  def archer_in_range?(direction=:forward)
    look(direction).any? { |s| s.unit && s.unit.name == "Archer" }
  end

  def wizard_in_range?(direction=:forward)
    look(direction).any? { |s| s.unit && s.unit.name == "Wizard" }
  end

  def enemies_visible?
    [:forward, :backward].any? { |d| enemy_in_range? d }
  end

  def captives_visible?
    [:forward, :backward].any? { |d| captive_in_range? d }
  end

  def range_clear?
    ! enemies_visible? && ! captives_visible?
  end

  def safe?
    [:forward, :backward].none? { |d| engaged? d } &&
    [:forward, :backward].none? {|d| archer_in_range? d }
  end

end
