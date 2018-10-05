defmodule Hiera.Backend.DataHash do

  def lookup_path(backend, path, name, options) do
    dict = backend.parse_path(path, options)
    if is_nil(dict) do
      {false, nil}
    else
      {Map.has_key?(dict, name), Map.get(dict, name)}
    end
  end

  @callback parse_path(String.t, Map.t) :: any

end


