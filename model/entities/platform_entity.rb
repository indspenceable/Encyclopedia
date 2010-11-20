module Model
  require './model/entities/entity.rb'
  class PlatformEntity < Entity
    attr_accessor :pos, :direction
    attr_accessor :level
    attr_accessor :vel
     
    #THIS IS WHAT YOU OVERRIDE
    def my_jump_strength
      2.3*th
    end
    def gravity
      0.003*th
    end
    def jump_strength
      (-Math.sqrt(2.0*gravity*my_jump_strength) - gravity)
    end

    def max_speed
      tiles_per_second = 5*tw
      tiles_per_second/30.0
    end
    def move_speed
      (max_speed/dampening)-max_speed
    end
    def dampening
      0.7
    end

    def initialize model, current_level, pos
      @vel = [0,0]
      @pos = pos
      @level = current_level 
      @model = model
    end

    #TODO fix these into parameters for the constructor!
    def my_width 
      0.75
    end
    def my_height
      1
    end

    def apply_velocity
      apply_x_velocity
      apply_y_velocity
    end

    def th; @level.TILE_SIZE[1]; end
    def tw; @level.TILE_SIZE[0]; end
    def convert_x x; x / tw; end
    def convert_y y; y / th; end
    def convert_pos p
      [(convert_x(p[0])+my_width/2).to_i, (convert_y(p[1])+my_height/2).to_i]
    end

    def apply_y_velocity 
      if @vel[1] >= 0
        new_y = @pos[1]+@vel[1]
        tile_new_y = (new_y/th).to_i + 1
        tile_old_x = ((@pos[0]/tw)).to_i
        tile_old_x_plus = ((@pos[0]/tw)+my_width-0.01).to_i
        #apply to floor
        unless @level.occupied?(tile_old_x,tile_new_y) || (@level.occupied?(tile_old_x_plus,tile_new_y))
          @pos[1] = new_y
          unflag :on_ground
          unflag :touch_cieling
        else
          @pos[1] = (tile_new_y-1)*th
          @vel[1] = 0
          flag :on_ground
          unflag :touch_cieling
        end
      elsif @vel[1] < 0
        new_y = @pos[1]+@vel[1]
        tile_new_y = (new_y/th).to_i()
        tile_old_x = ((pos[0])/tw).to_i
        tile_old_x_plus = ((pos[0]/tw)+my_width-0.01).to_i
        unless @level.occupied?(tile_old_x,tile_new_y) || (@level.occupied?(tile_old_x_plus,tile_new_y))
          @pos[1] = new_y
          unflag :on_ground
          unflag :touch_cieling
        else
          @pos[1] = (tile_new_y+1)*th 
          @vel[1] *= 4.0/5
          flag :touch_cieling
        end
      end 
    end
    def apply_x_velocity
      if @vel[0] > 0
        new_x = (@pos[0] + @vel[0])
        tile_new_x = ((new_x/tw)+my_width).to_i
        tile_old_y = (pos[1]/th)
        tile_old_y_plus = ((pos[1]/th)+0.85)
        unless @level.occupied?(tile_new_x,tile_old_y) || @level.occupied?(tile_new_x,tile_old_y_plus)

          #are we pushing?
          if (flag? :push_left) && !(flag? :on_ground) && vel[0]< 10
            #don't move
          else
            @pos[0] = new_x 
            unflag :push_right
            unflag :push_left
          end
        else
          @pos[0] = (tile_new_x-my_width)*tw
          @vel[0] = 0
          flag :push_right
        end
      elsif @vel[0] < 0
        new_x = (@pos[0] + @vel[0])
        tile_new_x = (new_x/tw).to_i
        tile_old_y = (pos[1]/th)
        tile_old_y_plus = ((pos[1]/th)+0.85)
        unless @level.occupied?(tile_new_x,tile_old_y) || @level.occupied?(tile_new_x,tile_old_y_plus)
          @pos[0] = new_x 
          unflag :push_left
          unflag :push_right
        else
          @pos[0] = (tile_new_x+1)*tw
          @vel[0] = 0
          flag :push_left
        end
      else
        #TODO - only unflag if we aren't up against a wall.
        unflag :push_left
        unflag :push_right
      end
    end

    def move
      flag :move
      if flag? :right
        @vel[0] += move_speed
        @direction = :right
      end
      if flag? :left
        @vel[0] -= move_speed
        @direction = :left
      end
    end
    def normalize_velocity
      if (@vel[1] < 0) && (flag? :unjump)
        @vel[1] /= 2
      end
      if @vel[0] != 0 
        @vel[0] = @vel[0]*dampening
        @vel[0] = 0 if @vel[0] > -dampening/5 && @vel[0] < dampening/5
      end
      2.times do |i|
        if @vel[i] > @level.TILE_SIZE[i]
          @vel[i] = @level.TILE_SIZE[i]
        elsif @vel[i] < -@level.TILE_SIZE[i]
          @vel[i] = -@level.TILE_SIZE[i]
        end
      end
    end
    def jump
      if flag? :jump
        if flag? :on_ground
          @vel[1] += JUMP
        end
      end
    end
    def apply_gravity
      @vel[1] += gravity
    end
    def tick 
      apply_gravity
      move
      normalize_velocity
      apply_velocity
      jump
      #@flags.clear
    end
  end
end
