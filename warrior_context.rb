module WarriorContext

  def required_health
    puts "next_spaces: #{next_spaces}"
    case next_spaces
    when / S./
      13
    when / aa/
      11
    when /  a/
      11
    when / a./
      7
    when / s./
      7
    else
      0
    end
  end

  def next_spaces
    look.map(&:character).join
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
