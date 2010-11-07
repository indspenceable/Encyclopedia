class Level
  attr_reader :Width, :Height
  def initialize width, height
    @Width = width
    @Height= height
    @tiles = Array.new(width) { |x| Array.new(height) { |y| (y>20 && (x<20 || x>27)|| y > 25) } }
  end
  def setup_level
  end
  def occupied?(x,y,direction = :down)
    @tiles[x][y]
  end
end
