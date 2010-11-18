module Levels
  module Level2
    def door pos
      self.on_activation(pos) do
        @model.goto_level(:level1, :gabe)
      end
      self.add_static(pos, :sign)
    end

  end
end