require 'pry'
require 'forwardable'
require 'logging'
require 'eventable'
require 'warrior_state'
require 'warrior_context'
require 'action_chooser'

include ColorLogging

class Player
  extend Forwardable
  include Eventable
  include WarriorState
  include WarriorContext
  include ActionChooser

  attr_reader :warrior

  def_delegators :warrior, *[
    :health,
    :feel,
    :look,
    :listen,
  ]

  on :game_start, :initialize_game
  on :turn_finish, :increment_turn

  def play_turn(warrior)
    trigger :game_start, warrior if first_turn?
    trigger :turn_start
    warrior.send *best_action
    trigger :turn_finish
  end

private

  def initialize_game(warrior)
    @turn    = 1
    @warrior ||= warrior
  end

  def increment_turn
    @turn += 1
  end

  def first_turn?
    @turn.nil? || @turn == 1
  end

end
