require 'rubygame'

module View
  class Animator
    def initialize
      #for animations
      @animations = {}
      @tile_sizes = {}
      @current_frames = {}

      #for tilesets
      @tile_data = {}
      @tiles = {}

      @fonts = {}

    end
    def load_sprites image_name, tile_size, animation_hash
      surf = Rubygame::Surface.load("assets/#{image_name}")
      reverse_surf = Rubygame::Surface.new [surf.w,surf.h]
      reverse_surf.fill [0,255,0, 255]

      tmp_surf = Rubygame::Surface.new tile_size
  
      (surf.w.to_f/tile_size[0]).ceil.times do |x|
        (surf.h.to_f/tile_size[1]).ceil.times do |y|
          #blit to the tmp surface
          tmp_surf.fill [255, 0, 255]
          tmp_surf.colorkey = [255, 0, 255]
          surf.blit(tmp_surf, [0,0], [x*tile_size[0],y*tile_size[1],tile_size[0],tile_size[1]])
          tmp_surf.to_display_alpha.zoom([-1,1]).blit(reverse_surf, [x*tile_size[0],y*tile_size[1]])
        end
      end

      reverse_surf = reverse_surf.to_display_alpha
      animation_hash.keys.each do |k|
        @tile_sizes[k] = tile_size
        pos, len, ticks_per_frame = animation_hash[k]
        @animations[k] = [surf, reverse_surf, pos, len, ticks_per_frame]
      end
    end
    def tile_set image_name, tile_size, auto_tiles_hash
      surf = Rubygame::Surface.load("assets/#{image_name}")
      xs = [0,BORDER_LEFT,BORDER_LEFT|BORDER_RIGHT,BORDER_RIGHT]
      ys = [0,BORDER_DOWN,BORDER_DOWN|BORDER_UP,BORDER_UP]
      auto_tiles_hash.each_pair do |k,v|
        xs.each_index do |x|
          ys.each_index do |y|
            @tile_data[k] = [surf, tile_size]
            new_val = [v[0]+x, v[1]+y]
            current_offsets = xs[x]|ys[y]
            new_key = [k, current_offsets]
            @tiles[new_key] = new_val
          end
        end
      end
    end

    def load_font(file, name, size = 12)
      Rubygame::TTF.setup
      @fonts[name] = Rubygame::TTF.new("assets/fonts/#{file}", size)

    end

    def animate obj, animation, dest_surf, location, reverse = false, static = nil
      r = reverse ? 1 : 0
      finished_animation = false
      # have we been animating this object?
      if @current_frames.key? obj
        anim,frame = @current_frames[obj]
        if anim == animation
          #go to the next frame in this animation
          frame = (frame+1)% (@animations[animation][4] * @animations[animation][3]) unless static
          finished_animation = ((frame+1)% (@animations[animation][4] * @animations[animation][3]) == 0)
          @current_frames[obj] = [animation,frame]
        else
          @current_frames[obj] = [animation,0]
        end
      else
        @current_frames[obj] = [animation, 0]
      end

      frame = @current_frames[obj][1]/@animations[animation][4]
      tile_x_size, tile_y_size = @tile_sizes[animation]
      tile_x, tile_y = @animations[animation][2]
      #[tile_x_size, tile_y_size,tile_x,tile_y].each do |c|
      #end
      @animations[animation][r].blit(dest_surf, location, [(tile_x+frame)*tile_x_size, tile_y*tile_y_size, tile_x_size, tile_y_size])
      finished_animation
    end

    def place_tile tile, borders, dest_surf, location
      surf, pos= @tile_data[tile]
      w,h = pos
      tile_x, tile_y = @tiles[[tile,borders]]
      surf.blit(dest_surf, location, [tile_x*w,tile_y*h,w,h])
    end

    def text(display_string, font_name, target, rect, color = [0,0,0])
      x,y,w,h = rect
      dest = [x,y] 
      @fonts[font_name].render(display_string, false, color).blit(target,dest) if display_string != ""
    end
  end
end
