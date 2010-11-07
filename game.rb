require './level'
class Game
  def initialize
    @animator = Animator.new
    @animator.load('player.png',
                   [16,16], 
                   { :walk => [[0,0],8,3],
                     :idle => [[0,1],2,15],
                     :filled => [[0,2],1,15],
                     :empty => [[0,3],1,15]})
    @level = Level.new 50,50

    @p = Player.new @level
    InputHandler.instance.register(@p)
    #lets precompute the background
    @level_surf = Rubygame::Surface.new [50*16,50*16]
    50.times do |x|
      50.times do |y|
        a = [16*x, 16*y]
        @animator.static(:filled, @level_surf, a) if @level.occupied?(x,y)
        @animator.static(:empty, @level_surf, a) unless @level.occupied?(x,y)
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
    #@animator.animate(:hello, @p.animation, screen, @p.pos.map{|v| (v/16.0).to_i*16})
  end
end
