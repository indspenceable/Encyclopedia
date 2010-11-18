def gabe pos
  self.on_activation(pos) do
    @model.goto_level(:level2, :door)
  end
  self.add_static(pos, :door)
end
