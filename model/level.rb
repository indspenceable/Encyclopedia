require 'YAML'
module Model
  class Level
    attr_reader :Width, :Height, :TILE_SIZE
    def self.load level_name
      tiles = YAML.load_file "assets/levels/#{level_name}/tiles.yaml"
      scripts = YAML.load_file "assets/levels/#{level_name}/scripts.yaml"
      require "./assets/levels/#{level_name}/script_module.rb"
      l = Level.new 
      l.instance_variable_set(:@tiles, tiles)
      l.instance_variable_set(:@scripts, scripts)
      l.instance_variable_set(:@TILE_SIZE, [20,20])
      mod = Levels.const_get(const_name = level_name.capitalize.to_sym)
      l.extend mod

      scripts.each_pair do |location, script|
        puts "SCRIPT IS #{script} #{script.class} LOCATION IS #{location} #{location.class}"
        l.send(script.to_sym, location)
      end

      l.instance_variable_set(:@Width, tiles.length)
      l.instance_variable_set(:@Height, tiles[0].length)
      l
    end
    
    def occupied?(x,y,direction = :down)
      @tiles[x][y] == :full
    end
  end
end
