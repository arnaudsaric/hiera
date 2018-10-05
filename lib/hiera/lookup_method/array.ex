defmodule Hiera.LookupMethod.Array do
  @behaviour Hiera.LookupMethod
  def init_acc, do: []
  def reducer({true, elements}, acc), do: {:cont, acc ++ elements}
  def reducer({false, _}, acc), do: {:cont, acc}
end
