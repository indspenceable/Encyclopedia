module Model
  class Static
    attr_accessor :pos, :current_animation, :animate, :direction
    def initialize pos, current_animation, direction = :left, animate = false
      @pos = pos
      @current_animation = current_animation
      @animate = animate
      @direction = direction
    end
  end
end
