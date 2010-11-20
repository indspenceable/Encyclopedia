require 'set'
module Model
  require './model/entities/platform_entity.rb'

  class Player < PlatformEntity
    react_to :key_pressed_space, ->(_){ flag :jump }
    react_to :key_release_space, ->(_){ flag :unjump}
    react_to :key_pressed_z, ->(_){ flag :punch }
    react_to :key_down_space, ->(_){flag :grab}
    react_to [:key_down_right, :key_down_left], ->(key){ flag key }
    react_to :key_pressed_up, ->(_){ @level.activate_at(convert_pos(@pos)) }
    react_to :key_down_r, ->(_){flag :run}

    react_to :key_pressed_down, ->(_) { if flag? :rock; unflag :rock; else; flag :rock; end }


    def gravity
      if flag? :rock
        0.3*th
      else
        super
      end
    end

    def max_walk
      5
    end
    def max_run
      7
    end
    def max_speed
      tiles_per_second = ((flag? :run) ? max_run : max_walk )*tw
      tiles_per_second/30.0
    end
  
    def dampening
      if flag? :on_ground
        super
      else
        0.8
      end
    end

    def current_animation
      if flag? :rock
        :rock
      elsif flag? :climb
        :climb
      elsif (flag? :push_right) && !(flag? :on_ground)
        :slide
      elsif (flag? :push_left) && !(flag? :on_ground)
        :slide
      elsif @vel[1] < 0
        #jump
        :jump
      elsif @vel[1] > 0
        #fall
        :fall
      elsif @vel[0] > 0
        :walk
      elsif @vel[0] < 0
        :walk
      else
        :idle
      end
    end
    def jump
      if (flag? :jump) && !(flag? :rock)
        if flag? :on_ground
          @vel[1] = jump_strength
          unflag :last_jump_left
          unflag :last_jump_right
          return
        elsif (flag? :push_left) || (flag? :push_right)
          if (flag? :push_left)&& (!flag? :last_jump_right)
            @vel[1] = jump_strength
            unflag :last_jump_left
            flag :last_jump_right
            @model.add_effect([:star, @pos.dup, true])
            return
          elsif (flag? :push_right) && (!flag? :last_jump_left)
            @vel[1] = jump_strength
            @model.add_effect([:star, @pos.dup, true])
            unflag :last_jump_right
            flag :last_jump_left
            return
          end
        end
        if (flag? :double_jump)
          @vel[1] = jump_strength
          @model.add_effect([:bounce, @pos.dup, @direction])
          unflag :double_jump
        end
      end
    end
    def apply_gravity
      unless (flag? :grab)&&(flag? :touch_cieling)
        unflag :climb
        @vel[1] += gravity
      else
        flag :climb
        @vel[1] = -0.1
      end
    end
    def tick 
      if flag? :rock
        unflag :left
        unflag :right
      end
      on_ground = flag? :on_ground
      super
      if (!on_ground) && (flag? :on_ground)
        @model.add_effect [:dust, @pos.dup, @direction]
      end
      if flag? :punch
        npos = @pos.dup
        @model.add_effect [:punch, @pos.dup, @direction]
      end
      @model.add_effect [:static, @pos.dup, @direction] if (flag? :push_right)||(flag? :push_left)
      @model.add_effect [:dust, @pos.dup, @direction] if (flag? :on_ground)&& (@vel[0]).abs > max_walk
      
      flag :double_jump if flag?(:on_ground)
      [:run, :grab,:jump, :unjump, :left, :right, :punch].each do |k|
        unflag k
      end
    end
  end
end
