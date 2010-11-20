module Levels
  module Intro_chamber
    def start pos
    end

    def read_warning_sign pos
      self.on_activation(pos, :text) do
        "Warning: sudden drop."
      end
      self.add_static(pos, :sign)
    end

    def door_level1 pos
      self.on_activation(pos) do
        @model.goto_level(:level1, :gabe)
      end
      self.add_static(pos, :door)
    end

  end
end