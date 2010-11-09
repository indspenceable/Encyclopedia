require 'set'
module Model
  need 'platform_entity.rb'
  class Monster < PlatformEntity
    def initialize current_level
      super current_level, [300,30]
      @frame = 0
    end
    def current_animation
      :walk
    end
    def tick
      @frame+=1
      flag :left if @frame < 5
      if @frame == 20
        flag :jump
        @frame = 0
      end
      super
    end
  end
end
