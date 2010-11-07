require 'singleton'
require 'rubygame'

class Animator
  def initialize
    @animations = {}
    @tile_sizes = {}
    @current_frames = {}
    puts "Tile sizes is #{@tile_sizes}"
  end
  def load image_name, tile_size, animation_hash, prefix = ""
    surf = Rubygame::Surface.load(image_name)
    @tile_sizes[surf] = tile_size
    animation_hash.keys.each do |k|
      pos, len, ticks_per_frame = animation_hash[k]
      @animations[k] = [surf, pos, len, ticks_per_frame]
    end
  end

  def animate obj, animation, dest_surf, location
    # have we been animating this object?
    if @current_frames.key? obj
      anim,frame = @current_frames[obj]
      if anim == animation
        #go to the next frame in this animation
        frame = (frame+1)% (@animations[animation][3] * @animations[animation][2])
        @current_frames[obj] = [animation,frame]
      else
        @current_frames[obj] = [animation,0]
      end
    else
      @current_frames[obj] = [animation, 0]
    end

    frame = @current_frames[obj][1]/@animations[animation][3]
    tile_x_size, tile_y_size = @tile_sizes[@animations[animation][0]]
    tile_x, tile_y = @animations[animation][1]
    #[tile_x_size, tile_y_size,tile_x,tile_y].each do |c|
    #end
    @animations[animation][0].blit(dest_surf, location, [(tile_x+frame)*tile_x_size, tile_y*tile_y_size, tile_x_size, tile_y_size])
  end

  def static animation, dest_surf, location
    tile_x_size, tile_y_size = @tile_sizes[@animations[animation][0]]
    tile_x, tile_y = @animations[animation][1]
    @animations[animation][0].blit(dest_surf,location,[tile_x*tile_x_size,tile_y*tile_y_size,tile_x_size,tile_y_size])
  end

end
