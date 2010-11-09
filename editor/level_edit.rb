require 'rubygame'
require 'YAML'

class Editor

  attr_accessor :th, :tw
  def current_tile
    @tiles[@tile_index] 
  end
  def next_tile
    @tile_index = (@tile_index+1)% (@tiles.size)
  end

  def update_level_surf_at(x,y)
    @empty_surf.blit(@level_surf, [x*16,y*16]) if :empty == @level[x][y]
    @filled_surf.blit(@level_surf, [x*16,y*16]) if :full == @level[x][y]
  end

  def save
    File.open(ARGV[2], "w") do |file|
      file << YAML.dump(@level)
    end
  end

  def edit
    screen = Rubygame::Screen.new [640,480]
    (events = Rubygame::EventQueue.new).enable_new_style_events
    @selector = Rubygame::Surface.load('selector.png')

    @tiles = [:empty, :full]
    @empty_surf = Rubygame::Surface.new [16,16]
    @empty_surf.fill([0,0,0])

    @filled_surf = Rubygame::Surface.new [16,16]
    @filled_surf.fill([255,0,0])

    @tile_index = 0

    @th = 16
    @tw = 16

    mx = 0
    my = 0

    if ARGV.size > 3
      @level = YAML.load_file(ARGV[3])
    else
      @level = Array.new (ARGV[0].to_i) { Array.new(ARGV[1].to_i) { :empty } }
    end




    @level_surf = Rubygame::Surface.new [16*ARGV[0].to_i, 16*ARGV[1].to_i]
    @level.each_index do |x|
      @level[x].each_index do |y|
        update_level_surf_at(x,y)
      end
    end

    changed = false

    loop do
      events.each do |e|
        if e.is_a?(Rubygame::Events::KeyPressed)&&e.key == :space
          save
        end
        raise "goodbye!" if e.is_a? Rubygame::Events::QuitRequested
        if e.is_a?(Rubygame::Events::MousePressed)||e.is_a?(Rubygame::Events::MouseMoved)
          changed = true
          mx,my = e.pos
          if (e.is_a?(Rubygame::Events::MousePressed) && e.button == :mouse_left) || (e.is_a?(Rubygame::Events::MouseMoved) && e.buttons.include?(:mouse_left))
            @level[mx/tw][my/th] = current_tile
            update_level_surf_at(mx/tw, my/th)
          end
        end
        if e.is_a?(Rubygame::Events::MousePressed) && e.button == :mouse_right
          next_tile
        end
      end
      # draw
      if changed
        screen.fill [0,0,0]
        @level_surf.blit(screen, [0,0])
        @selector.blit(screen,[(mx/tw)*tw,(my/th)*th])
      end
      changed = false
      screen.update

    end
  ensure
    Rubygame.quit
  end
end

if ARGV.size >= 3
  Editor.new.edit
else
  puts "Usage: rsdl level_edit.rb <WIDTH><HEIGHT><OUTPUT>[LOAD]"
end
