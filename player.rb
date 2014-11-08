require 'eventable'
require 'action_chooser'

class Player
  include Eventable
  include ActionChooser

  attr_reader :warrior

  on :game_start, :initialize_game
  on :turn_finish, :increment_turn

  def play_turn(warrior)
    trigger :game_start, warrior if first_turn?
    trigger :turn_start
    warrior.public_send *best_action
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
