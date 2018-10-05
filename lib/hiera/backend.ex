defmodule Hiera.Backend do
  @callback lookup_path(String.t, String.t, Map.t) :: any
end

