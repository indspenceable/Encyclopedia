require 'rubygame'

ManagerQuitError = Class.new(RuntimeError)

module Manager
  def self.run model, view, controller, target_frames_per_second = 60
    clock = Rubygame::Clock.new
    clock.target_framerate = target_frames_per_second

    loop do
      controller.handle_events model

      model.tick

      view.draw model

      clock.tick
    end
  rescue ManagerQuitError
  ensure
    Rubygame.quit
  end
end
