def read_sign pos
  self.on_activation(pos, :text) do
    "This sign appears to be blank."
  end
  self.add_static(pos, :sign)
end
