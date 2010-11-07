require './input_handler.rb'
require './entity.rb'
require './manager.rb'


class TestEnt < Entity
  react_to :key_pressed_space, ->(){ puts self; @entity_state = :ready }
  react_to :key_release_space, ->(){ @entity_state = :not_ready }
  react_to :key_pressed_k, ->(){ puts "Ok!" }, :ready
end

#this is our event handler
class Game
  def tick
    puts "Game#tick"
  end
  def draw screen
    puts "Game#draw"
  end
end

InputHandler.instance.register(TestEnt.new)
g = Game.new

Manager.run [640,480], g,g, [255,255,255]

