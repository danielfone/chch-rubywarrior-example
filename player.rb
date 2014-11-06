require 'pry'
require 'forwardable'
require_relative 'logging'
require_relative 'warrior_state'

include ColorLogging

class Player
  extend Forwardable
  include WarriorState

  attr_reader :warrior, :prev_health

  def_delegators :warrior, *[
    :health,
    :feel,
    :look,
    :listen,
  ]

  def play_turn(warrior)
    before_game(warrior) if first_turn?
    before_turn
    warrior.send *choose_action
    after_turn
  end

private

  def choose_action
    case current_state
    when :taking_damage then taking_damage_action
    when :hurting       then hurting_action
    when :ready_to_go   then ready_to_go_action
    end
  end

  def before_game(warrior)
    @turn        = 1
    @prev_health ||= 0
    @warrior     ||= warrior
    @seen_rear_wall = false
  end

  def before_turn
    #@seen_rear_wall = true if feel(:backward).wall?
    @direction = :forward
    @archer_direction = [:backward, :left, :right].find { |d| archer_in_range?(d) }
    @enemy_direction = [:backward, :left, :right].find { |d| enemy_in_range?(d) }
    @captive_direction = [:backward, :left, :right].find { |d| captive_in_range?(d) }
    @stairs_direction = [:backward, :left, :right].find { |d| stairs_in_range?(d) }
  end

  def after_turn
    @prev_health = health
    @turn += 1
  end

  def first_turn?
    @turn.nil? || @turn == 1
  end

  def taking_damage_action
    case
    when health_critical?
      [:walk!, :backward]
    when engaged?
      :attack!
    when clear_shot_on_enemy?
      :shoot!
    else
      :walk!
    end
  end

  def hurting_action
    case
    when level_clear?
      go_to_stairs
    when safe?
      :rest!
    else
      [:walk!, :backward]
    end
  end

  def ready_to_go_action
    # Deal with enemies
    return [:pivot!, @archer_direction]   if @archer_direction
    return [:pivot!, @enemy_direction]  if @enemy_direction
    return :attack! if engaged?
    return :shoot!  if clear_shot_on_enemy?

    # Deal with captives
    return [:pivot!, @captive_direction]  if @captive_direction
    return :rescue! if near_captive?

    # navigate
    return [:pivot!, :backward]  if blocked?
    return [:pivot!, @stairs_direction] if @stairs_direction
    go_to_stairs if level_clear?
    return :walk!
  end

  def go_to_stairs
    return [:pivot!, @stairs_direction] if @stairs_direction
    return :walk!
  end

  def clear_shot_on_enemy?
    units = look.select { |s| s.unit }
    units.any? && units.first.enemy?
  end

  def engaged?(direction=@direction)
    feel(direction).enemy?
  end

  def near_captive?
    feel(@direction).captive?
  end

  def blocked?
    feel(@direction).wall?
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

  def level_clear?
    stairs_in_range? && ! enemy_in_range? && ! captive_in_range?
  end

  def safe?
    [:forward, :backward, :left, :right].none? { |d| engaged? d } &&
    [:forward, :backward, :left, :right].none? {|d| archer_in_range? d }
  end

end

module WarriorContext

end
