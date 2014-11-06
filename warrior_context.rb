module WarriorContext

  def clear_shot_on_enemy?
    units = look.select { |s| s.unit }
    units.any? && units.first.enemy?
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

  def sludge_in_range?(direction=:forward)
    look(direction).any? { |s| s.unit && s.unit.name == "Sludge" }
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
