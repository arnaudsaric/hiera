defmodule Hiera.Backend.Helpers do

  def readable?(fname) do
    case File.open(fname, [:read]) do
      {:ok, handle} -> 
        File.close handle
        true
      _ -> false
    end
  end

end
