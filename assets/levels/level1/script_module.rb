module Levels
  module Level1
    def read_sign pos
      self.on_activation(pos, :text) do
        "This sign appears to be blank."
      end
      self.add_static(pos, :sign)
    end

    def spawn_weevil pos
      self.spawn(Model::Weevil, pos) do
        
      end
    end
    def spawn_bird pos
      self.spawn(Model::Bird, pos) do
        
      end
    end
    def gabe pos
      self.on_activation(pos) do
        @model.goto_level(:level2, :door)
      end
      self.add_static(pos, :door)
    end

    def start pos
    end

  end
end