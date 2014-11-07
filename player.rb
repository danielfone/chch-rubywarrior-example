require 'pry'
require 'forwardable'
require 'logging'
require 'eventable'
require 'warrior_state'
require 'warrior_context'

include ColorLogging

class Player
  extend Forwardable
  include Eventable
  include WarriorState
  include WarriorContext

  attr_reader :warrior, :prev_health

  def_delegators :warrior, *[
    :health,
    :feel,
    :look,
    :listen,
  ]

  on :game_start, :initialize_game
  on :turn_start, :before_turn
  on :turn_finish, :after_turn


  def play_turn(warrior)
    trigger :game_start, warrior if first_turn?
    trigger :turn_start
    warrior.send *choose_action
    trigger :turn_finish
  end

private

  def choose_action
    case current_state
    when :taking_damage then taking_damage_action
    when :hurting       then hurting_action
    when :ready_to_go   then ready_to_go_action
    end
  end

  def initialize_game(warrior)
    @turn        = 1
    @warrior     ||= warrior
  end

  def before_turn
    @direction = :forward
    @archer_direction = [:backward].find { |d| archer_in_range?(d) }
    @enemy_direction = [:backward].find { |d| enemy_in_range?(d) }
    @captive_direction = [:backward].find { |d| captive_in_range?(d) }
    @stairs_direction = [:backward].find { |d| stairs_in_range?(d) }
    (@needs_health = false; puts_color(ANSI_GREEN, "Fighting fit")) if @needs_health && health >= @required_health
  end

  def after_turn
    @turn += 1
  end

  def first_turn?
    @turn.nil? || @turn == 1
  end

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
    puts "next_unit_name: #{next_unit_name} — need #{required_health}"
    if !@needs_health && health < required_health
      @required_health = required_health
      @needs_health = true
      puts_color(ANSI_RED, "Need rest!")
    end

    case
    when @needs_health && safe?
      :rest!
    when @needs_health && !safe?
      @required_health += 3 # accounts for archers
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

end
