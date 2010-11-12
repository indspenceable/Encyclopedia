require 'rubygame'

module Controller
  class Controller
    #include Singleton
    include Rubygame::EventHandler::HasEventHandler
    def handle_events
      @event_queue.each do |e|
        handle e
      end
    end
    def initialize model
      @event_queue = Rubygame::EventQueue.new
      @event_queue.enable_new_style_events
      @keys = {}
      make_magic_hooks(
        {Rubygame::Events::KeyPressed => ->(owner, event){ model.keys[event.key] = :pressed },
          Rubygame::Events::KeyReleased => ->(owner,event){ model.keys[event.key] = :release },
          Rubygame::Events::QuitRequested => ->(_,_){ raise ManagerQuitError.new }})
    end
  end
end
