module View
  def self.need f
    require File.join(File.dirname(File.expand_path(__FILE__)),f)
  end
  need 'animator.rb'

  BORDER_LEFT = 1
  BORDER_RIGHT = 2
  BORDER_UP = 4
  BORDER_DOWN = 8

  class View
    def initialize screen_size, background
      @screen = Rubygame::Screen.new screen_size
      @buffer = Rubygame::Surface.new [screen_size[0]*2, screen_size[1]*2]
     
      @background = background

      @effects = []
      @to_delete = []

      @animator = Animator.new
      @animator.load_sprites('anims.png',
                     [16,16], 
                     { :idle => [[0,0],4,10],
                       :walk => [[0,1],2,10],
                       :slide => [[0,2],2,10],
                       :climb => [[0,3],2,10],
                       :empty => [[0,4],1,10],
                       :bounce => [[2,1],4,6],
                        :static => [[2,2],4,3],
                        :star => [[2,3],4,7],
                        :punch => [[2,4],4,7],
                        :sign => [[4,0],1,1]
      })
      @animator.load_font('font.ttf',:font,12)

      @animator.tile_set('tiles.png',
                           [16,16],
                           { :test => [0,4] })
      @view_box =  [30, screen_size[1]-200-30, screen_size[0]-60,200]
      @scroll_offset = [0,0]
      @translated_positions = Hash.new
    end
    def cache_level level
      puts "LEVEL WIDTH IS #{level.Width}"
      puts "LEVEL HEIGHT IS #{level.Height}"
      @level_surf = Rubygame::Surface.new [level.Width*16,level.Height*16]
      @level_surf.fill [0,0,255]
      50.times do |x|
        50.times do |y|
          a = [16*(x), 16*(y)]
          if level.occupied?(x,y)
            borders = 0
            borders |= BORDER_UP if (y > 0) && level.occupied?(x,y-1)
            borders |= BORDER_DOWN if (y < 49) && level.occupied?(x,y+1)
            borders |= BORDER_RIGHT if (x > 0) && level.occupied?(x-1,y)
            borders |= BORDER_LEFT if (x < 49) && level.occupied?(x+1,y)
            @animator.place_tile(:test, borders, @level_surf, a)
          end
          @animator.animate(:h, :empty, @level_surf, a) unless level.occupied?(x,y)
        end
      end
    end

    def convert_pos e, p, level_tile_size
      @translated_positions[e] ||= [0,0]
      2.times do |x|
        @translated_positions[e][x] = p[x]/level_tile_size[x] * 16 + @scroll_offset[x]
      end
      @translated_positions[e]
    end

    def set_scroll_location model, level_tile_size
      @scroll_offset[0] = -model.focal_point[0]
      @scroll_offset[1] = -model.focal_point[1]
      2.times do |x|
        @scroll_offset[x] = @scroll_offset[x]/level_tile_size[x] * 16
      end
      @scroll_offset[0] += @screen.w/2
      @scroll_offset[1] += @screen.h/2
      @scroll_offset[0] = 0 if @scroll_offset[0] > 0
      @scroll_offset[1] = 0 if @scroll_offset[1] > 0
    end


    def draw model
      #TODO - clean into multiple methods
      @screen.fill @background
      @buffer.fill @background
      cache_level model.level unless @level_surf
      middle = [0,0]
      #first, lets determine where we should scroll to
      set_scroll_location model, model.level.TILE_SIZE

      @level_surf.blit(@buffer,@scroll_offset)

      model.level.entities.each do |e|
        @animator.animate(e, e.current_animation, @buffer, convert_pos(e,e.pos,model.level.TILE_SIZE), e.direction==:left, model.display_string)
      end

      @effects += model.get_effects
      @effects.each do |e|
        @to_delete << e if @animator.animate(e, e[0], @buffer, convert_pos(e, e[1],model.level.TILE_SIZE), e[2]==:left, model.display_string)
      end
      @effects -= @to_delete
      @to_delete.clear

      if model.display_string
        x,y,w,h = @view_box
        @buffer.draw_box_s([x,y],[x+w,y+h],[0,255,255]) 
        @animator.text(model.display_string, :font, @buffer, @view_box)
      end

      @buffer.blit(@screen,[0,0])
      @screen.update
    end
  end
end
