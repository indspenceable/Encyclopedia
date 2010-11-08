require 'rubygame'

module Manager
  def self.run model, view, controller, target_frames_per_second = 60
    clock = Rubygame::Clock.new
    clock.target_framerate = target_frames_per_second

    loop do
      #handle events
      controller.handle_events model

      model.tick

      view.draw model

      clock.tick
    end
  rescue Controller::ManagerQuitError
  ensure
    Rubygame.quit
  end
end
