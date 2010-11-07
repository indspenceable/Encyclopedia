require './input_handler.rb'
require './entity.rb'
require './manager.rb'
require './animator.rb'

require 'set'

class Shot < Entity
  react_to [:collide], :hit
  attr_accessor :pos
  def initialize pos, dirs
    @pos = pos
    @direction = dirs
  end
  def hit
    puts "lol"
  end

  def tick
    @direction.each do |direction|
      case direction
      when :right 
        @pos[0] += 1
      when :left 
        @pos[0] -= 1
      when :up 
        @pos[1] -= 1
      when :down 
        @pos[1] += 1
      end
    end
  end
end

#define the player - on press
class Player < Entity
  attr_accessor :pos, :animation
  react_to [:key_down_right, :key_down_left, :key_down_up, :key_down_down], :move
  react_to [:key_pressed_space], :shoot
  def initialize
    @pos = [20,20]
    @animation = :idle
    @cd = Set.new
    @old_cd = Set.new
  end
  def shoot key
    G.shots << Shot.new(@pos.dup,@cd.dup)
  end
  def move key
    case key
    when :right 
      (@cd.include? :left)? @cd.delete(:left) : @cd << :right
      @pos[0] += 1
    when :left 
      (@cd.include? :right)? @cd.delete(:right) : @cd << :left
      @pos[0] -= 1
    when :up 
      (@cd.include? :down)? @cd.delete(:down): @cd << :up
      @pos[1] -= 1
    when :down 
      (@cd.include? :up)? @cd.delete(:up): @cd << :down
      @pos[1] += 1
    end
    @moved = true
  end

  def tick
    if @moved
      @animation = :walk
      @old_cd = @cd
      @cd = Set.new
    else
      @cd = @old_cd
      @animation = :idle
    end
    @moved = false
  end
end

#this is our event handler
class ZeldaGame
  attr_accessor :shots
  def initialize
    @player = Player.new
    InputHandler.instance.register(@player)
    @enemies = []
    @shots = []
    @animator = Animator.new
    @animator.load('player.png',
                   [16,16], 
                   { :walk => [[0,0],2,15],
                     :idle => [[0,1],2,15] })
    @animator.load('weapons.png',
                   [4,4],
                   { :zap => [[0,0],2,5] })
  end
  def tick
    @player.tick
    @shots.each {|s| s.tick}
  end
  def draw screen
    @animator.animate(@player, @player.animation, screen, @player.pos)
    @shots.each do |s|
      @animator.animate(s, :zap, screen, s.pos)
    end
  end
end
G = ZeldaGame.new
Manager.run [640,480], G,G, [255,255,255]

