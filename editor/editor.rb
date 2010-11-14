require 'rubygame'
require 'YAML'
require 'set'

LEVEL_PATH = "./editor/levels/"

X_SIZE = 200
Y_SIZE = 200

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
    Dir.mkdir "#{LEVEL_PATH}#{ARGV[0]}" unless File.directory?("#{LEVEL_PATH}#{ARGV[0]}")
    File.open("#{LEVEL_PATH}#{ARGV[0]}/level.yaml", "w") { |file| file << YAML.dump(@level) }
    File.open("#{LEVEL_PATH}#{ARGV[0]}/scripts.yaml", "w") { |file| file << YAML.dump(@scripts) }
    @scripts.values.uniq.each do |script|
      puts "SCRIPT IS #{script}"
      unless File.exist?("#{LEVEL_PATH}#{ARGV[0]}/#{script}.rb")
        File.open("#{LEVEL_PATH}#{ARGV[0]}/#{script}.rb", "w") do |file|
          file << "def #{script} model, x, y\n  # Enter your script here.\nend"
        end
      end
    end
  end


  def edit
    puts "HI"
    screen = Rubygame::Screen.new [640,480]
    (events = Rubygame::EventQueue.new).enable_new_style_events
    @selector = Rubygame::Surface.load('./editor/selector.png')

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

    if File.directory?("#{LEVEL_PATH}#{ARGV[0]}")
      @level = YAML.load_file("#{LEVEL_PATH}#{ARGV[0]}/level.yaml")
      @scripts = YAML.load_file("#{LEVEL_PATH}#{ARGV[0]}/scripts.yaml")
    else
      @level = Array.new (X_SIZE) { Array.new(Y_SIZE) { :empty } }
      @scripts = Hash.new
    save
    end

    @level_surf = Rubygame::Surface.new [16*X_SIZE, 16*Y_SIZE]
    @level.each_index do |x|
      @level[x].each_index do |y|
        update_level_surf_at(x,y)
      end
    end
    changed = false
    mode = :edit

    current_script_name = ""

    offset = [0,0]
    

    loop do
      events.each do |e|
        if e.is_a?(Rubygame::Events::KeyPressed) && mode == :edit
          changed = true
          case e.key
          when :space
            save
          when :z
            mode = :script
            current_script_name = ""
          when :right
            offset[0] += 1 if offset[0]+(screen.w/@tw) < @level.length()-1
          when :left
            offset[0] -= 1 if offset[0] > 0
          when :down
            offset[1] += 1 if offset[1]+(screen.h/@th) < @level[0].length() -1
          when :up
            offset[1] -= 1 if offset[1] > 0
          end
        elsif e.is_a?(Rubygame::Events::KeyPressed) && mode == :script
          if e.key == :escape
            mode = :edit
          elsif e.key == :backspace
            if current_script_name.size > 0
              current_script_name = current_script_name[0,current_script_name.size-1]
            end
          elsif /[a-zA-Z]/.match(e.string)
            current_script_name += e.string
          elsif e.key == :space || e.key == :minus
            current_script_name += "_"
          else
            #puts "We are ignoring: #{e.key} with #{e.modifiers}"
          end
        end
        raise "goodbye!" if e.is_a? Rubygame::Events::QuitRequested
        if nil
          #elsif e.key == :return
        end
        if (e.is_a?(Rubygame::Events::MousePressed)||e.is_a?(Rubygame::Events::MouseMoved))
          changed = true
          mx,my = e.pos
          if mode == :edit
            if (e.is_a?(Rubygame::Events::MousePressed) && e.button == :mouse_left) || (e.is_a?(Rubygame::Events::MouseMoved) && e.buttons.include?(:mouse_left))
              @level[mx/tw + offset[0]][my/th + offset[1]] = current_tile
              update_level_surf_at(mx/tw + offset[0], my/th + offset[1])
            end
          elsif e.is_a? Rubygame::Events::MousePressed
            current_script_name.strip!
            @scripts[[mx/tw,my/th]] = current_script_name
            mode = :edit
            puts "Saved #{current_script_name}"
            save
          end
        end
        if e.is_a?(Rubygame::Events::MousePressed) && e.button == :mouse_right
          next_tile
        end
      end
      # draw
      if changed
        screen.fill [0,0,0]
        @level_surf.blit(screen, [-offset[0]*@tw, -offset[1]*@th])
        @selector.blit(screen,[(mx/tw)*tw,(my/th)*th]) if mode == :edit
        if mode == :script
          @scripts.keys.each do |k|
            @selector.blit(screen,[k[0]*tw,k[1]*th])
          end
        end
      end
      changed = false
      screen.update

    end
  ensure
    Rubygame.quit
  end
end

if ARGV.length != 1
  puts "you just put in a level name. Thats it. come on!"
else
  Editor.new.edit
end

