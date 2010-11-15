module Levels
  module Level1
    def spawn_weevil pos
      self.spawn(Model::Weevil, pos) do
        
      end
    end
    def read_sign pos
      self.on_activation(pos, :text) do
        "This sign appears to be blank."
      end
      self.spawn(Model::Sign, pos)
    end

  end
end