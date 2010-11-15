require './model/entities/platform_entity.rb'
module Model
  class Weevil < PlatformEntity
    def initialize *args
      super
      @direction = :left
    end
    def current_animation
      :walk
    end
    def tick
      flag @direction
      super
      unflag @direction
      if flag? :push_right
        puts "hi"
        @direction = :right 
      end
    end
  end
end
