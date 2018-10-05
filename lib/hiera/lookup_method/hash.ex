defmodule Hiera.LookupMethod.Hash do
  @behaviour Hiera.LookupMethod
  def init_acc, do: %{}
  def reducer({true, element}, acc), do: {:cont, Map.merge(element, acc)}
  def reducer({false, _}, acc), do: {:cont, acc}
end
