require 'pry'
require 'forwardable'
require 'logging'
require 'warrior_state'
require 'warrior_context'

include ColorLogging

class Player
  extend Forwardable
  include WarriorState
  include WarriorContext

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
    @archer_direction = [:backward].find { |d| archer_in_range?(d) }
    @enemy_direction = [:backward].find { |d| enemy_in_range?(d) }
    @captive_direction = [:backward].find { |d| captive_in_range?(d) }
    @stairs_direction = [:backward].find { |d| stairs_in_range?(d) }
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
    when range_clear?
      go_to_stairs
    when safe? && enemies_visible? && health_not_optimal?
      :rest!
    when engaged?
      :attack!
    when !safe?
      [:walk!, :backward]
    else
      :walk!
    end
  end

  def ready_to_go_action
    # Deal with enemies
    return [:pivot!, @archer_direction]   if @archer_direction
    return [:pivot!, @enemy_direction]  if @enemy_direction
    return :attack! if engaged?
    return :walk!   if sludge_in_range?
    return :shoot!  if clear_shot_on_enemy?

    # Deal with captives
    return [:pivot!, @captive_direction]  if @captive_direction
    return :rescue! if near_captive?

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

end
