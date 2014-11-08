module WarriorContext

  def next_spaces
    look.map(&:character).join
  end

  def next_unit_name(direction=:forward)
    next_unit_space = look(direction).find { |s| s.unit }
    next_unit_space.unit.name if next_unit_space
  end

  def clear_shot_on_wizard?
    next_unit_name == 'Wizard'
  end

  def engaged?(direction=:forward)
    feel(direction).enemy?
  end

  def next_to_captive?(direction=:forward)
    feel(direction).captive?
  end

  def blocked?
    feel.wall?
  end

  def enemy_visible?(direction=:forward)
    look(direction).any? &:enemy?
  end

  def captive_visible?(direction=:forward)
    look(direction).any? &:captive?
  end

  def stairs_visible?(direction=:forward)
    look(direction).any? &:stairs?
  end

  def archer_visible?(direction=:forward)
    look(direction).any? { |s| s.unit && s.unit.name == "Archer" }
  end

  def wizard_visible?(direction=:forward)
    look(direction).any? { |s| s.unit && s.unit.name == "Wizard" }
  end

  def enemies_visible?
    [:forward, :backward].any? { |d| enemy_visible? d }
  end

  def captives_visible?
    [:forward, :backward].any? { |d| captive_visible? d }
  end

  def range_clear?
    ! enemies_visible? && ! captives_visible?
  end

  def safe?
    [:forward, :backward].none? { |d| engaged? d } &&
    [:forward, :backward].none? {|d| archer_visible? d }
  end

end
