module Model
  need 'entity.rb'
  class PlatformEntity < Entity
    attr_accessor :pos

    GRAVITY = 0.3
    JUMP = -8
    def initialize current_level, pos
      @vel = [0,0]
      @pos = pos
      @level = current_level 
    end

    def apply_velocity
      apply_x_velocity
      apply_y_velocity
    end

    def th
      @level.TILE_SIZE[1]
    end

    def tw
      @level.TILE_SIZE[0]
    end
    def apply_y_velocity
      if @vel[1] > 0
        new_y = @pos[1]+@vel[1]
        tile_new_y = (new_y/th).to_i
        tile_old_x = (@pos[0]/tw).to_i
        tile_old_x_plus = ((@pos[0]/tw)+0.95).to_i
        #apply to floor
        unless @level.occupied?(tile_old_x,tile_new_y+1) || (@level.occupied?(tile_old_x_plus,tile_new_y+1))
          @pos[1] = new_y
        else
          @pos[1] = (tile_new_y)*th
          @vel[1] = 0
          flag :on_ground
        end
      elsif @vel[1] < 0
        new_y = @pos[1]+@vel[1]
        tile_new_y = (new_y/th).to_i
        tile_old_x = ((pos[0])/tw).to_i
        unless @level.occupied?(tile_old_x,tile_new_y)
          @pos[1] = new_y
        else
          @pos[1] = (tile_new_y+1)*th
          @vel[1] = 0
          flag :on_ground
        end
      end 
    end
    def apply_x_velocity
      if @vel[0] > 0
        new_x = (@pos[0] + @vel[0])
        tile_new_x = (new_x/tw).to_i+1
        tile_old_y = (pos[1]/th)
        tile_old_y_plus = ((pos[1]/th)+0.95)
        unless @level.occupied?(tile_new_x,tile_old_y) || @level.occupied?(tile_new_x,tile_old_y_plus)
          @pos[0] = new_x 
        else
          @pos[0] = (tile_new_x-1)*tw
          @vel[0] = 0
          flag :right_wall
        end
      elsif @vel[0] < 0
        new_x = (@pos[0] + @vel[0])
        tile_new_x = (new_x/tw).to_i
        tile_old_y = (pos[1]/th)
        tile_old_y_plus = ((pos[1]/th)+0.95)
        unless @level.occupied?(tile_new_x,tile_old_y) || @level.occupied?(tile_new_x,tile_old_y_plus)
          @pos[0] = new_x 
        else
          @pos[0] = (tile_new_x+1)*tw
          @vel[0] = 0
          flag :left_wall
        end
      end
    end

    def move
      flag :move
      @vel[0] += 0.9 if flag? :right
      @vel[0] -= 0.9 if flag? :left
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
    def tick
      @vel[1] += GRAVITY #unless flag? :on_ground
      move
      apply_velocity
      jump if flag? :jump
      normalize_velocity
      @flags.clear
    end
    def jump
      if flag? :on_ground
        @vel[1] += JUMP
      end
    end
  end
end
