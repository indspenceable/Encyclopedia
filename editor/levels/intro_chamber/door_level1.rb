def door_level1 pos
  self.on_activation(pos) do
    @model.goto_level(:level1, :gabe)
  end
  self.add_static(pos, :door)
end
