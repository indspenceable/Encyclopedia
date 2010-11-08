module View
  def self.need f
    require File.join(File.dirname(File.expand_path(__FILE__)),f)
  end
  need 'animator.rb'
  class View
    def initialize screen_size, background
      @screen = Rubygame::Screen.new screen_size
      @background = background

      @animator = Animator.new
      @animator.load('player.png',
                     [16,16], 
                     { :walk => [[0,0],8,3],
                       :idle => [[0,1],2,15],
                       :filled => [[0,2],1,15],
                       :empty => [[0,3],1,15]})
    end
    def cache_level level
      @level_surf = Rubygame::Surface.new [50*16,50*16]
      50.times do |x|
        50.times do |y|
          a = [16*x, 16*y]
          @animator.static(:filled, @level_surf, a) if level.occupied?(x,y)
          @animator.static(:empty, @level_surf, a) unless level.occupied?(x,y)
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
    def draw model
      @screen.fill @background
      cache_level model.level unless @level_surf
      @level_surf.blit(@screen, [0,0]) 
      model.entities.each do |e|
        @animator.animate(e, e.animation, @screen, e.pos)
      end
      @screen.update
    end
  end
end
