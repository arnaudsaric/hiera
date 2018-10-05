defmodule Hiera.LookupMethod.Simple do
  @behaviour Hiera.LookupMethod
  def init_acc, do: nil
  def reducer({true, element}, _), do: {:halt, element}
  def reducer({false, _}, _), do: {:cont, nil}
end
