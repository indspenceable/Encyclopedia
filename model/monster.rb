module Model
  need 'platform_entity.rb'
  class Monster < PlatformEntity
    def initialize current_level
      super current_level, [30,30]
      @frame = 0
    end
    def current_animation
      :slug
    end
    def tick 
      @frame+=1
      flag :left if @frame < 5
      @frame = 0 if @frame > 20
      super
    end
  end
end
