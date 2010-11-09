require 'YAML'
module Model
  class Level
    attr_reader :Width, :Height, :TILE_SIZE
    def self.load fname
      tiles = YAML.load_file fname
      level = Level.new tiles.size, tiles[0].size
      tiles.each_index do |x|
        tiles[x].each_index do |y|
          level.set x,y,tiles[x][y]
        end
      end
      level
    end
    def initialize width, height
      @Width = width
      @Height= height
      @TILE_SIZE = [8,8]
      @tiles = Array.new(width) { |x| Array.new(height) { |y| (y>20 && (x<20 || x>27)|| y > 25) } }
    end
    def set x,y, val
      @tiles[x][y] = val
    end
    def setup_level
    end
    def occupied?(x,y,direction = :down)
      @tiles[x][y] == :full
    end
  end
end
