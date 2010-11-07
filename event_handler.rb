require 'singleton'
require 'rubygame'

class InputHandler
  include Singleton
  include Rubygame::EventHandler::HasEventHandler

  def register(e)
    @input_entities << e
  end

  def initialize
    @input_entities = []
    @keys = {}
    make_magic_hooks(
      {Rubygame::Events::KeyPressed => ->(owner, event){ @keys[event.key] = :pressed },
        Rubygame::Events::KeyReleased => ->(owner,event){ @keys[event.key] = :release },
        Rubygame::Events::QuitRequested => ->(_,_){ raise "QUIT" }})
  end

  def tick
    @input_entities.each do |e|
      @keys.each_pair do |k,v|
        e.handle ("key_" + v.to_s + "_" + k.to_s).to_sym if v != :down
        e.handle ("key_down_"+k.to_s).to_sym if v != :release
      end
    end
    @keys.delete_if{ |k,v| v == :release }
    @keys.keys.each { |k| @keys[k] = :down }
  end

end

