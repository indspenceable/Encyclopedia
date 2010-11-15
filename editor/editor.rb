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
    puts "NEXT"
    @tile_index = (@tile_index+1)% (@tiles.size)
    puts "index is now #{@tile_index}"
  end

  def update_level_surf_at(x,y)
    @empty_surf.blit(@level_surf, [x*16,y*16]) if :empty == @level[x][y]
    @filled_surf.blit(@level_surf, [x*16,y*16]) if :full == @level[x][y]
  end

  Rules = { (/\Aread_(.*)\z/) => [->(match){'on_activation(pos, :text)'}, '"This sign appears to be blank."'],
    (/\Aspawn_(.*)\z/) => [->(match){ "spawn(Model::#{match[1].capitalize}, pos)"}, "" ] }

  def save
    Dir.mkdir "#{LEVEL_PATH}#{ARGV[0]}" unless File.directory?("#{LEVEL_PATH}#{ARGV[0]}")
    File.open("#{LEVEL_PATH}#{ARGV[0]}/level.yaml", "w") { |file| file << YAML.dump(@level) }
    File.open("#{LEVEL_PATH}#{ARGV[0]}/scripts.yaml", "w") { |file| file << YAML.dump(@scripts) }
    @scripts.values.uniq.each do |script|
      puts "SCRIPT IS #{script}"
      unless File.exist?("#{LEVEL_PATH}#{ARGV[0]}/#{script}.rb") || script.strip ==
        File.open("#{LEVEL_PATH}#{ARGV[0]}/#{script}.rb", "w") do |file|
          file << "def #{script} pos\n"
          any = false
          Rules.each_pair do |k,v|
            if script =~ k 
              file << "  self.#{v[0].call k.match(script)} do\n"
              file << "    #{v[1]}\n"
              file << "  end\n"
              any = true
            end
          end
          file << "Enter the code for this event here.\n" unless any
          file << "end"
        end
      end
    end
    puts "*click*"
    puts "Your level has been saved."
  end

  def edit_keypress e
    puts "EDIT"
    @changed = true
    case e.key
    when :space
      save
    when :z
      @mode = :script
      @current_script_name = ""
    when :right
      @offset[0] += 1 if @offset[0]+(@screen.w/@tw) < @level.length()-1
    when :left
      @offset[0] -= 1 if @offset[0] > 0
    when :down
      @offset[1] += 1 if @offset[1]+(@screen.h/@th) < @level[0].length() -1
    when :up
      @offset[1] -= 1 if @offset[1] > 0
    end
  end
  def script_keypress e
    if e.key == :escape
      @mode = :edit
      @changed = true
    elsif e.key == :backspace
      if @current_script_name.size > 0
        @current_script_name = @current_script_name[0,@current_script_name.size-1]
      end
    elsif /[a-zA-Z1-9]/.match(e.string)
      @current_script_name += e.string
    elsif e.key == :space || e.key == :minus
      @current_script_name += "_"
    else
      #puts "We are ignoring: #{e.key} with #{e.modifiers}"
    end
  end

  def mouse_press e
    @changed = true
    @mx,@my = e.pos
    if @mode == :edit
      if (e.is_a?(Rubygame::Events::MousePressed) && e.button == :mouse_left) || (e.is_a?(Rubygame::Events::MouseMoved) && e.buttons.include?(:mouse_left))
        @level[@mx/tw + @offset[0]][@my/th + @offset[1]] = current_tile
        update_level_surf_at(@mx/tw + @offset[0], @my/th + @offset[1])
      end
    elsif e.is_a? Rubygame::Events::MousePressed
      @current_script_name.strip!
      if @current_script_name == ""
        @scripts.delete([@mx/tw,@my/th])
      else
        @scripts[[@mx/tw,@my/th]] = @current_script_name
      end
      @mode = :edit
      save
    end
  end

  def process_event e
    raise "goodbye!" if e.is_a? Rubygame::Events::QuitRequested
    if e.is_a?(Rubygame::Events::KeyPressed) && @mode == :edit
      edit_keypress e
    elsif e.is_a?(Rubygame::Events::KeyPressed) && @mode == :script
      script_keypress e
    elsif (e.is_a?(Rubygame::Events::MousePressed)||e.is_a?(Rubygame::Events::MouseMoved))
      mouse_press e
    end
    if e.is_a?(Rubygame::Events::MousePressed) && e.button == :mouse_right
      next_tile
    end
  end

  def edit
    puts "HI"
    @screen = Rubygame::Screen.new [640,480]
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

    @mx = 0
    @my = 0

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
    @changed = false
    @mode = :edit

    @current_script_name = ""

    @offset = [0,0]
    loop do
      events.each do |e|
        process_event e
      end
      # draw
      if @changed
        @screen.fill [0,0,0]
        @level_surf.blit(@screen, [-@offset[0]*@tw, -@offset[1]*@th])
        @selector.blit(@screen,[(@mx/tw)*tw,(@my/th)*th]) if @mode == :edit
        if @mode == :script
          @scripts.keys.each do |k|
            @selector.blit(@screen,[k[0]*tw,k[1]*th])
          end
        end
      end
      @changed = false
      @screen.update

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

