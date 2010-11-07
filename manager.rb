require 'rubygame'
require './input_handler'


module Manager
  def self.run screen_size, display, event_handler, background_color, target_frames_per_second = 60
    screen = Rubygame::Screen.new screen_size
    queue = Rubygame::EventQueue.new
    queue.enable_new_style_events
    handler = InputHandler.instance

    clock = Rubygame::Clock.new
    clock.target_framerate = target_frames_per_second

    loop do
      queue.each do |e|
        handler.handle(e)
      end
      event_handler.tick
      handler.tick
      screen.fill background_color
      if display.is_a? Proc
        display.call(screen)
      else
        display.draw(screen)
      end
      screen.update
      clock.tick
    end
  rescue InputHandler::ManagerQuitError
  ensure
    Rubygame.quit
  end
end
