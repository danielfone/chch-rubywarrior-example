require 'eventable'
require 'action_chooser'

class Player
  include Eventable
  include ActionChooser

  attr_reader :warrior

  def play_turn(warrior)
    @warrior ||= warrior
    trigger :turn_start
    warrior.public_send *best_action
    trigger :turn_finish
  end

end
