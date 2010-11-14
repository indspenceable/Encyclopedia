module Model
  need 'entity.rb'
  class PlatformEntity < Entity
    attr_accessor :pos, :direction

    GRAVITY = 0.3
    JUMP = -8
    def initialize model, current_level, pos
      @vel = [0,0]
      @pos = pos
      @level = current_level 
      @model = model
    end

    def apply_velocity 
      apply_x_velocity 0.75, 1
      apply_y_velocity 0.75, 1
    end

    def th; @level.TILE_SIZE[1]; end
    def tw; @level.TILE_SIZE[0]; end
    def convert_x x; x / tw; end
    def convert_y y; y / th; end
    def convert_pos p
      [convert_x(p[0]), convert_y(p[1])]
    end

    def apply_y_velocity my_width, my_height
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
    def apply_x_velocity my_width, my_height
      if @vel[0] > 0
        new_x = (@pos[0] + @vel[0])
        tile_new_x = ((new_x/tw)+my_width).to_i
        tile_old_y = (pos[1]/th)
        tile_old_y_plus = ((pos[1]/th)+0.85)
        unless @level.occupied?(tile_new_x,tile_old_y) || @level.occupied?(tile_new_x,tile_old_y_plus)
          @pos[0] = new_x 
          unflag :push_left
          unflag :push_right
        else
          @pos[0] = (tile_new_x-my_width)*tw
          @vel[0] = 0
          flag :push_left
        end
      elsif @vel[0] < 0
        new_x = (@pos[0] + @vel[0])
        tile_new_x = (new_x/tw).to_i
        tile_old_y = (pos[1]/th)
        tile_old_y_plus = ((pos[1]/th)+0.85)
        unless @level.occupied?(tile_new_x,tile_old_y) || @level.occupied?(tile_new_x,tile_old_y_plus)
          @pos[0] = new_x 
          unflag :push_right
          unflag :push_left
        else
          @pos[0] = (tile_new_x+1)*tw
          @vel[0] = 0
          flag :push_right
        end
      else
        unflag :push_right
        unflag :push_left
      end
    end

    def move
      flag :move
      if flag? :right
        @vel[0] += 0.9
        @direction = :right
      end
      if flag? :left
        @vel[0] -= 0.9
        @direction = :left
      end
    end
    def normalize_velocity
      if (@vel[1] < 0) && (flag? :unjump)
        @vel[1] /= 2
      end
      if @vel[0] != 0 
        @vel[0] = @vel[0]*4/6.0
        @vel[0] = 0 if @vel[0] > -0.5 && @vel[0] < 0.5
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
      puts "APPLY GRAVITY"
      @vel[1] += GRAVITY
    end
    def tick 
      apply_gravity
      move
      apply_velocity
      jump
      normalize_velocity
      #@flags.clear
    end
  end
end
