module Model
  class Sign < StaticEntity
    def initialize model, level, pos
      super pos, :sign
    end
  end
end
