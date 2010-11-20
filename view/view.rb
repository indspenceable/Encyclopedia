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
      @screen.fill background
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
                       :bounce => [[2,1],4,6],
                        :static => [[2,2],4,3],
                        :star => [[2,3],4,7],
                        :punch => [[2,4],4,7],
                        :sign => [[4,0],1,1],
                        :door => [[5,0],1,1],
                        :dust => [[0,4],4,3]
      }) do
        @screen.update
      end
      @animator.load_sprites('player.png',
                             [16,16],
                             { :walk => [[2,2],4,12],
                               :fall => [[7,1],2,12],
                               :rock => [[6,1],1,20],
                               :jump => [[9,1],2,12] }) do
        @screen.update
        print "."
                               end
      puts "" 
      @animator.load_font('font.ttf',:font,12)

      @animator.tile_set('tiles.png',
                         [16,16],
                         { :full => [4,4],
                           :empty => [4,0]})
      @view_box =  [30, screen_size[1]-200-30, screen_size[0]-60,200]
      @scroll_offset = [0,0]
      @translated_positions = Hash.new
      @level_surfs = {}
    end

    def slow_cache_level level, steps_to_complete
      return if (@current_cache ||= Hash.new)[level] == :finished
      #surface, total, current
      surf, total, current = (@current_cache[level] ||= [Rubygame::Surface.new([level.Width*16, level.Height* 16]), level.Width*level.Height-1, 0])
      steps_to_complete = total - current if total - current < steps_to_complete
      steps_to_complete.times do |k|
        y = (current+k)/level.Width
        x = (current+k) % level.Width;
        a = [16*x, 16*y]
        current_tile = level.tile_at(x,y)
        borders = 0
        borders |= BORDER_UP if (y > 0) && level.tile_at(x,y-1) == current_tile
        borders |= BORDER_DOWN if (y < level.Height-1) && level.tile_at(x,y+1) == current_tile
        borders |= BORDER_RIGHT if (x > 0) && level.tile_at(x-1,y) == current_tile
        borders |= BORDER_LEFT if (x < level.Width-1) && level.tile_at(x+1,y) == current_tile
        @animator.place_tile(current_tile, borders, surf, a)
      end
      if current + steps_to_complete == total
        @level_surfs[level] = surf
        @current_cache[level] = :finished
      else
        @current_cache[level][2] += steps_to_complete
      end
    end

    def cache_level level
      @level_surfs[level] = Rubygame::Surface.new [level.Width*16,level.Height*16]
      @level_surfs[level].fill [0,0,255]
      level.Width.times do |x|
        level.Height.times do |y|
          a = [16*(x), 16*(y)]
          current_tile = level.tile_at(x,y)
          borders = 0
          borders |= BORDER_UP if (y > 0) && level.tile_at(x,y-1) == current_tile
          borders |= BORDER_DOWN if (y < level.Height-1) && level.tile_at(x,y+1) == current_tile
          borders |= BORDER_RIGHT if (x > 0) && level.tile_at(x-1,y) == current_tile
          borders |= BORDER_LEFT if (x < level.Width-1) && level.tile_at(x+1,y) == current_tile
          @animator.place_tile(current_tile, borders, @level_surfs[level], a)
          # @animator.animate(:h, :empty, @level_surfs[level], a) unless level.occupied?(x,y)
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

    def draw_level level
      @level_surfs[level] ||= Rubygame::Surface.new [level.Width*16,level.Height*16]
      (@level_fills ||= Hash.new)[level] ||= Set.new
      start_x = -@scroll_offset[0].to_i/16
      start_y = -@scroll_offset[1].to_i/16
      @d_l_pos ||= [0,0]
      (start_x..start_x+@screen.w/16).each do |x|
        (start_y..start_y+@screen.h/16).each do |y|
          @d_l_pos[0] = x
          @d_l_pos[1] = y
          unless @level_fills[level].include?(@d_l_pos)
            @level_fills[level] << @d_l_pos
            a = [16*(x), 16*(y)]
            current_tile = level.tile_at(x,y)
            borders = 0
            borders |= BORDER_UP if (y > 0) && level.tile_at(x,y-1) == current_tile
            borders |= BORDER_DOWN if (y < level.Height-1) && level.tile_at(x,y+1) == current_tile
            borders |= BORDER_RIGHT if (x > 0) && level.tile_at(x-1,y) == current_tile
            borders |= BORDER_LEFT if (x < level.Width-1) && level.tile_at(x+1,y) == current_tile
            @animator.place_tile(current_tile, borders, @level_surfs[level], a)
          end
        end
      end
    end

    def draw model
      #TODO - clean into multiple methods
      @screen.fill @background
      @buffer.fill @background


      #unless @level_surfs[model.level]
      #  slow_cache_level model.level, 1000
      #  @screen.fill [0,255,rand(256)]
      #  @screen.update
      #  return
      #end
      middle = [0,0]
      #first, lets determine where we should scroll to
      set_scroll_location model, model.level.TILE_SIZE

      draw_level model.level
      @level_surfs[model.level].blit(@buffer,@scroll_offset)

      model.level.statics.each do |s|
        @animator.animate(s, 
                          s.current_animation, 
                          @buffer, 
                          convert_pos(s,s.pos,model.level.TILE_SIZE), 
                          s.direction==:left, 
                          s.animate || model.display_string)
      end

      vel = 0
      model.level.entities.each do |e|
        vel = e.vel
        @animator.animate(e, 
                          e.current_animation, 
                          @buffer, 
                          convert_pos(e,e.pos,model.level.TILE_SIZE), 
                          e.direction==:left, 
                          model.display_string)
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
