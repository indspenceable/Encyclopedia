module Levels
  module Level1
    def hello pos
      # Enter your script here.
    end
    def read_sign pos
      # Enter your script here.
      self.on_activation(:text) do
        puts "HELLO WORLD"
        'hi'
      end
    end

  end
end