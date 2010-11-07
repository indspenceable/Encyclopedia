require 'singleton'
require 'rubygame'

class InputHandler
  include Singleton
  include Rubygame::EventHandler::HasEventHandler

  class ManagerQuitError < RuntimeError
  end
  def register(e)
    @input_entities << e
  end

  def initialize
    @input_entities = []
    @keys = {}
    make_magic_hooks(
      {Rubygame::Events::KeyPressed => ->(owner, event){ @keys[event.key] = :pressed },
        Rubygame::Events::KeyReleased => ->(owner,event){ @keys[event.key] = :release },
        Rubygame::Events::QuitRequested => ->(_,_){ raise ManagerQuitError.new }})
  end

  def tick
    @keys.each_pair do |key, value|
      @input_entities.each { |e| e.handle ("key_"+value.to_s+"_"+key.to_s).to_sym, key }
    end
    @keys.delete_if{ |k,v| v == :release }
    @keys.keys.each { |k| @keys[k] = :down }
  end

end

