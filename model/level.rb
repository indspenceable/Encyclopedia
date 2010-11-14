require 'YAML'
module Model
  class Level
    attr_reader :Width, :Height, :TILE_SIZE
    def initialize tiles, scripts, ts, model
      @tiles = tiles
      @scripts = scripts
      @TILE_SIZE = ts
      @model = model

      @active_locations = {}
    end
    def self.load level_name, model
      tiles = YAML.load_file "assets/levels/#{level_name}/tiles.yaml"
      scripts = YAML.load_file "assets/levels/#{level_name}/scripts.yaml"
      require "./assets/levels/#{level_name}/script_module.rb"
      l = Level.new tiles, scripts, [20,20], model
      #l.instance_variable_set(:@tiles, tiles)
      #l.instance_variable_set(:@scripts, scripts)
      #l.instance_variable_set(:@TILE_SIZE, [20,20])
      #l.instance_variable_set(:@model, model)

      mod = Levels.const_get(const_name = level_name.capitalize.to_sym)
      l.extend mod
      scripts.each_pair do |location, script|
        l.send(script.to_sym, location)
      end

      l.instance_variable_set(:@Width, tiles.length)
      l.instance_variable_set(:@Height, tiles[0].length)
      l
    end
    
    def occupied?(x,y,direction = :down)
      @tiles[x][y] == :full
    end

    def on_activation(location, pos, &block)
      @active_locations[pos] = block
    end

    def activate_at(pos)
      puts "activate_at #{pos.inspect}"
      puts "locations are #{@active_locations.inspect}"
      if @active_locations.key? pos
        @active_locations[pos].call()
      end
    end

  end
end
