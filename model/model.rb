require 'set'
module Model
  def self.need f
    require File.join(File.dirname(File.expand_path(__FILE__)),f)
  end
  need 'level.rb'
  need 'monster.rb'
  need 'player.rb'

  class Model
    attr_reader :input_entities
    attr_reader :entities
    attr_reader :level

    attr_reader :keys
    attr_accessor :display_string
    def focal_point
      @p.pos
    end

    def initialize
      @level = Level.load('level1', self)
      #@level = Level.new 50,50
      #(20..25).each do |x|
      #  @level.set(x,16)
      #end
      @p = Player.new self, @level, [100,100]
      @input_entities = Set.new << @p
      @monsters = Set.new
      @entities = @input_entities + @monsters
      #lets precompute the background
      @effects = []

      @keys = {}
    end

    def add_effect e
      @effects << e
    end
    def get_effects
      rtn = @effects
      @effects = []
      rtn
    end
    def process_controller_input
      if @display_string
        @display_string = nil if @keys[:space] == :pressed
      else
        @keys.each_pair do |key, value|
          input_entities.each { |e| e.handle ("key_"+value.to_s+"_"+key.to_s).to_sym, key }
        end
      end
      @keys.delete_if{ |k,v| v == :release }
      @keys.keys.each { |k| @keys[k] = :down }
    end
    def tick
      #calculate overlaps
      #we should forward input from the controller as appropriate here.
      process_controller_input
      unless @display_string
        entities.each do |e|
          e.tick
        end
      end
    end
  end
end
