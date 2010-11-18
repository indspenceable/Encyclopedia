require 'set'
module Model
  require './model/level.rb'
  require './model/entities/player.rb'
  require './model/entities/weevil.rb'
  require './model/entities/bird.rb'
  require './model/static.rb'

  class Model
    attr_reader :level

    attr_reader :keys
    attr_accessor :display_string
    def focal_point
      @p.pos
    end

    def initialize 
      @levels = {}
      goto_level(:intro_chamber, :start)
      
      
      #@level = Level.new 50,50
      #(20..25).each do |x|
      #  @level.set(x,16)
      #end
      @p = Player.new self, @level, [100,100]
      goto_level(:intro_chamber, :start)
      #lets precompute the background
      @effects = []

      @keys = {}
    end

    def goto_level(level_name, location)
      @levels[level_name] = Level.load(level_name.to_s, self) unless @levels.key? level_name
      @level = @levels[level_name]

      coords = @level.scripts.to_a.find{|v| v[1].to_sym == location}[0]

      @level.make_active_level
      if @p
        @level.entities << @p
        @p.level = @level
        @p.pos = [@level.TILE_SIZE[0]*coords[0], @level.TILE_SIZE[1]*coords[1]]
      end
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
          @p.handle ("key_"+value.to_s+"_"+key.to_s).to_sym, key
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
        level.entities.each do |e|
          e.tick
        end
      end
    end
  end
end
