module Model
  class StaticEntity < Entity
    attr_accessor :pos, :current_animation
    def initialize pos, current_animation
      @pos = pos
      @current_animation = current_animation
    end
    def tick *args; end
    def direction; :left end
  end
end
