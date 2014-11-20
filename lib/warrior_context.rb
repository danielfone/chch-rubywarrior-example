require 'forwardable'

module WarriorContext
  extend Forwardable

  def_delegators :warrior, *[
    :feel,
    :look,
  ]

  def next_spaces(direction=:forward)
    look(direction).map(&:character).join
  end

  def next_object(direction=:forward)
    next_spaces(direction).strip[0]
  end

  def clear_shot_on_wizard?
    next_object == 'w'
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

  def archer_ahead?
    next_spaces.include? 'a'
  end

  def wizard_ahead?
    next_spaces.include? 'w'
  end

  def enemies_visible?
    any_direction? { |d| enemy_visible? d }
  end

  def captives_visible?
    any_direction? { |d| captive_visible? d }
  end

  def range_clear?
    ! enemies_visible? && ! captives_visible?
  end

  def safe?
    ! engaged? && ! archer_ahead?
  end

  def stairs_direction
    if look(:backward).any? &:stairs?
      :backward
    else
      :forward
    end
  end

  def any_direction?(&block)
    [:forward, :backward].any? &block
  end

end
