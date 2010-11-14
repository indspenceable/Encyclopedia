require 'set'
module Model
  need 'platform_entity.rb'

  class Player < PlatformEntity
    react_to :key_pressed_space, ->(_){ flag :jump }
    react_to :key_release_space, ->(_){ flag :unjump}
    react_to :key_pressed_z, ->(_){ flag :punch }
    react_to :key_down_space, ->(_){flag :grab}
    react_to [:key_down_right, :key_down_left], ->(key){ flag key }
    react_to :key_down_p, ->(_){ @model.display_string = "Hello" }
    react_to :key_down_up, ->(_){ @level.activate_at(convert_pos(@pos)) }

    def current_animation
      if flag? :climb
        :climb
      elsif (flag? :push_left) && !(flag? :on_ground)
        :slide
      elsif (flag? :push_right) && !(flag? :on_ground)
        :slide
      elsif @vel[1] < 0
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
    def jump
      if flag? :jump
        if flag? :on_ground
          @vel[1] = JUMP
          unflag :last_jump_left
          unflag :last_jump_right
        elsif (flag? :push_right) || (flag? :push_left)
          if (flag? :push_right)&& (!flag? :last_jump_right)
            @vel[1] = JUMP
            unflag :last_jump_left
            flag :last_jump_right
            @model.add_effect([:star, @pos.dup, true])
          elsif (flag? :push_left) && (!flag? :last_jump_left)
            @vel[1] = JUMP
            @model.add_effect([:star, @pos.dup, true])
            unflag :last_jump_right
            flag :last_jump_left
          end
        elsif (flag? :double_jump)
          @vel[1] = JUMP
          @model.add_effect([:bounce, @pos.dup, @direction])
          unflag :double_jump
        end
      end
    end
    def apply_gravity
      unless (flag? :grab)&&(flag? :touch_cieling)
        unflag :climb
        @vel[1] += GRAVITY 
      else
        flag :climb
        @vel[1] = -0.1
      end
    end
    def tick 
      super
      if flag? :punch
        npos = @pos.dup
        @model.add_effect [:punch, @pos.dup, @direction]
      end
      
      @model.add_effect [:static, @pos.dup, @direction] if (flag? :push_left)||(flag? :push_right)
      flag :double_jump if flag?(:on_ground)
      [:grab,:jump, :unjump, :left, :right, :punch].each do |k|
        unflag k
      end
    end
  end
end
