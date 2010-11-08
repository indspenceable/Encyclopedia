module Model
  def self.need f
    require File.join(File.dirname(File.expand_path(__FILE__)),f)
  end
  need 'level.rb'
  need 'player.rb'

  class Model
    attr_reader :input_entities
    attr_reader :entities
    attr_reader :level

    def initialize
      @level = Level.new 50,50
      (20..25).each do |x|
        @level.set(x,16)
      end

      @p = Player.new @level
      @entities = @input_entities = [@p]
      #lets precompute the background
    end
    def tick
      @p.tick
    end
  end
end
