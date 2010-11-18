def read_warning_sign pos
  self.on_activation(pos, :text) do
    "Warning: sudden drop."
  end
  self.add_static(pos, :door)
end
