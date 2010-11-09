require 'rubygame'

module Controller
  class Controller
    #include Singleton
    include Rubygame::EventHandler::HasEventHandler

    def handle_events model
      @event_queue.each do |e|
        handle e
      end
      tick model
    end

    def register(e)
      @input_entities << e
    end

    def initialize
      @event_queue = Rubygame::EventQueue.new
      @event_queue.enable_new_style_events
      @keys = {}
      make_magic_hooks(
        {Rubygame::Events::KeyPressed => ->(owner, event){ @keys[event.key] = :pressed },
          Rubygame::Events::KeyReleased => ->(owner,event){ @keys[event.key] = :release },
          Rubygame::Events::QuitRequested => ->(_,_){ raise ManagerQuitError.new }})
    end

    def tick model
      @keys.each_pair do |key, value|
        model.input_entities.each { |e| e.handle ("key_"+value.to_s+"_"+key.to_s).to_sym, key }
      end
      @keys.delete_if{ |k,v| v == :release }
      @keys.keys.each { |k| @keys[k] = :down }
    end

  end

end
