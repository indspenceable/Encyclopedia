require 'set'
module Model
  need 'platform_entity.rb'

  class Player < PlatformEntity
    react_to :key_pressed_space, ->(_){ flag :jump }
    react_to [:key_down_right, :key_down_left], ->(key){ flag key }

    def initialize level
      super level, [30,30]
    end
    def current_animation
      if @vel[1] < 0
        #jump
        :walk
      elsif @vel[1] > 0
        #fall
        :walk
      elsif @vel[0] > 0
        :walk
      elsif @vel[0] < 0
        :walk
      else
        :idle
      end
    end
  end
end
