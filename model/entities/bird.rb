module Model
  class Bird < Weevil
    def initialize model, level, pos
      super
      @low_pos = pos.dup
      @low_pos[1] += 10
    end

    def current_animation
      :idle
    end

    def my_jump_strength
      1*th
    end
    def jump
      if flag? :jump
        @vel[1] = jump_strength
      end
    end

    def tick
      flag :jump if @pos[1] > @low_pos[1] && @vel[1] > 0
      super
      unflag :jump
    end
  end
end
