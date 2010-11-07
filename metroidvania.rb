require './input_handler.rb'
require './entity.rb'
require './manager.rb'
require './animator.rb'

require './player.rb'
require './game.rb'

G = Game.new
Manager.run [640,480], G,G, [255,255,255], 60
