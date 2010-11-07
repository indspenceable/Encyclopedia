require 'set'

class Player < Entity
  react_to :key_pressed_space, ->(_){ flag :jump_pressed }
  react_to [:key_down_right, :key_down_left], ->(key){ flag key }
  attr_accessor :pos, :animation

  GRAVITY = 0.3
  JUMP = -8
  TILE_WIDTH = 16
  TILE_HEIGHT= 16

  def initialize current_level
    @flags = Set.new
    @vel = [0,0]
    @pos = [30,30]
    @animation = :idle
    @level = current_level 
  end

  def jump
    if flag? :on_ground
      @vel[1] += JUMP
    end
  end

  def flag sym
    @flags << sym
  end
  def flag? sym
    @flags.include? sym
  end
  def unflag sym
    @flags.delete(sym)
  end

  def apply_velocity
    if @vel[1] > 0
      new_y = @pos[1]+@vel[1]
      tile_new_y = (new_y/16).to_i
      tile_old_x = (@pos[0]/16).to_i
      #apply to floor
      #TODO - fix, you can hang onto walls on the right
      unless @level.occupied?(tile_old_x,tile_new_y+1) #|| (@level[tile_old_x+1][tile_new_y+1])
        @pos[1] = new_y
      else
        @pos[1] = (tile_new_y)*16
        @vel[1] = 0
        flag :on_ground
      end
    elsif @vel[1] < 0
      new_y = @pos[1]+@vel[1]
      tile_new_y = (new_y/16).to_i
      tile_old_x = ((pos[0])/16).to_i
      unless @level.occupied?(tile_old_x,tile_new_y)
        @pos[1] = new_y
      else
        @pos[1] = (tile_new_y-1)*16
        @vel[1] = 0
        flag :on_ground
      end
    end 

    if @vel[0] > 0
      new_x = (@pos[0] + @vel[0])
      tile_new_x = (new_x/16).to_i+1
      tile_old_y = (pos[1]/16)
      unless @level.occupied?(tile_new_x,tile_old_y)
        @pos[0] = new_x 
      else
        @pos[0] = (tile_new_x-1)*16
        @vel[0] = 0
        flag :right_wall
      end
    elsif @vel[0] < 0
      new_x = (@pos[0] + @vel[0])
      tile_new_x = (new_x/16).to_i
      tile_old_y = (pos[1]/16)
      unless @level.occupied?(tile_new_x,tile_old_y)
        @pos[0] = new_x 
      else
        @pos[0] = (tile_new_x+1)*16
        @vel[0] = 0
        flag :left_wall
      end
    end

    #@pos[0] += @vel[0]
  end

  def move
    flag :move
    @vel[0] += 0.9 if flag? :right
    @vel[0] -= 0.9 if flag? :left
  end

  def set_current_animation
    @animation = 
      if @vel[1] < 0
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

  def normalize_velocity
    if @vel[0] != 0 
      @vel[0] = @vel[0]*4/6.0
      @vel[0] = 0 if @vel[0] > -0.5 && @vel[0] < 0.5
    end
    2.times do |i|
      if @vel[i] > 15
        @vel[i] = 15
      elsif @vel[i] < -15
        @vel[i] = -15
      end
    end
  end

  def tick
    @vel[1] += GRAVITY #unless flag? :on_ground
    move
    apply_velocity
    jump if flag? :jump_pressed
    normalize_velocity
    set_current_animation
    @flags.clear
  end
end
