require 'YAML'
module Model
  class Level
    TILE_SIZE = [300,300]
    def TILE_SIZE
      TILE_SIZE
    end
    attr_reader :Width, :Height
    attr_reader :entities
    attr_reader :statics
    attr_reader :scripts
    def initialize tiles, scripts, model
      @tiles = tiles
      @scripts = scripts
      #@TILE_SIZE = ts
      @model = model

    end
    def self.load level_name, model
      tiles = YAML.load_file "assets/levels/#{level_name}/tiles.yaml"
      scripts = YAML.load_file "assets/levels/#{level_name}/scripts.yaml"
      require "./assets/levels/#{level_name}/script_module.rb"
      l = Level.new tiles, scripts, model
      #l.instance_variable_set(:@tiles, tiles)
      #l.instance_variable_set(:@scripts, scripts)
      #l.instance_variable_set(:@TILE_SIZE, [20,20])
      #l.instance_variable_set(:@model, model)

      mod = Levels.const_get(const_name = level_name.capitalize.to_sym)
      l.extend mod

      l.instance_variable_set(:@Width, tiles.length)
      l.instance_variable_set(:@Height, tiles[0].length)


      #only execute the scripts on becoming the active level
      #scripts.each_pair do |location, script|
      #  l.send(script.to_sym, location)
      #end
      l
    end

    def make_active_level 
      @active_locations = {}
      @entities = []
      @statics = []
      @scripts.each_pair do |location, script|
        self.send(script.to_sym, location)
      end
    end
    
    def occupied?(x,y, direction = :down)
      @tiles[x][y] == :full
    end

    def tile_at(x,y)
      @tiles[x][y]
    end

    def on_activation(location, type = :action, &block)
      @active_locations[location] =
        case type
        when :text
          ->(){ @model.display_string = block.call() }
        when :action
          block
        end
    end

    def spawn(klass, pos)
      entities << klass.new(@model, self, [TILE_SIZE[0]*pos[0], TILE_SIZE[1]*pos[1]])
    end
    def add_static(pos, sym, direction = :left, animate = false)
      statics << Static.new([TILE_SIZE[0]*pos[0], TILE_SIZE[1]*pos[1]], sym, direction, animate = false)
    end
    def activate_at(pos)
      if @active_locations.key? pos
        @active_locations[pos].call()
      end
    end
  end
end
