defmodule Hiera.Backend.Yaml do

  @behaviour Hiera.Backend

  def lookup_path(path, name, options) do
    Hiera.Backend.DataHash.lookup_path(__MODULE__, path, name, options)
  end

  @behaviour Hiera.Backend.DataHash

  def parse_path(file, _options) do
    if Hiera.Backend.Helpers.readable? file do
      YamlElixir.read_from_file(file)
    end
  end

end

