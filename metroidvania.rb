require './input_handler.rb'
require './entity.rb'
require './manager.rb'
require './animator.rb'

require 'matrix'
require 'set'

class Player < Entity

  react_to :key_pressed_space, ->(_){ flag :jump_pressed }
  react_to [:key_down_right, :key_down_left], :move
  attr_accessor :pos, :animation


  def initialize current_level
    @flags = Set.new
    @vel = [0,0]
    @pos = [30,30]
    @animation = :idle
    @level = current_level 
  end

  def jump
    if flag? :on_ground
      @vel[1] -= 12
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
    new_y = @pos[1]+@vel[1]
    tile_new_y = (new_y/16+0.5).to_i
    tile_old_x = (pos[0]/16)
    unless @level[tile_old_x][tile_new_y+1]
      @pos[1] = new_y
    else
      @pos[1] = (tile_new_y)*16
      @vel[1] = 0
      flag :on_ground
    end
    @pos[0] += @vel[0]
  end

  def move key
      flag :move
      @vel[0] += (key==:right) ? (5) : (-5)
  end

  def set_current_animation
    @animation = 
      if @vel[0] != 0
        :walk
      else
        :idle
      end
  end

  def normalize_velocity
    if @vel[0] != 0 
      unless flag? :on_ground
        @vel[0] = @vel[0]*4/6.0
        @vel[0] = 0 if @vel[0] > -0.5 && @vel[0] < 0.5
      end
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
    @vel[1] += 1 unless flag? :on_ground
    apply_velocity
    jump if flag? :jump_pressed

    #normalize velocity
    normalize_velocity

    set_current_animation
    @flags.clear
  end
end

class Game
  def initialize
    @animator = Animator.new
    @animator.load('player.png',
                   [16,16], 
                   { :walk => [[0,0],2,15],
                     :idle => [[0,1],2,15],
                     :filled => [[0,2],1,15],
                     :empty => [[0,3],1,15]})
    @level = Array.new(50) { |x| Array.new(50) { |y| (y>20 && x < 20|| y > 25) } }

    @p = Player.new @level
    InputHandler.instance.register(@p)
    #lets precompute the background
    @level_surf = Rubygame::Surface.new [50*16,50*16]
    50.times do |x|
      50.times do |y|
        a = [16*x, 16*y]
        @animator.static(:filled, @level_surf, a) if @level[x][y]
        @animator.static(:empty, @level_surf, a) unless @level[x][y]
      end
    end

    return
    Animator.cache(@level, [50*16, 50*16]) do |s|
      50.times do |x|
        50.times do |y|
          a = [16*x, 16*y]
          @animator.animate(:level, :filled, s, a) if @level[x][y]
        end
      end
    end
  end
  def tick
    @p.tick
  end
  def draw screen
    @level_surf.blit(screen, [0,0]) 
    @animator.animate(@p, @p.animation, screen, @p.pos.to_a)
  end
end
G = Game.new

Manager.run [640,480], G,G, [255,255,255], 60
