defmodule Hiera.Utils do

  #  def enum_ops(enum, l) do
  #    Enum.reduce(enum, [], build_reducer l)
  #    |> Enum.reverse
  #  end
  #
  #  defp build_reducer([]) do
  #    &([&1 | &2])
  #  end
  #  defp build_reducer([map: f]) do
  #    &([f.(&1) | &2])
  #  end
  #  defp build_reducer([filter: f]) do
  #    &(if f.(&1), do: [&1 | &2], else: &2)
  #  end
  #
  #  defp build_transformer(l, f_acc\\&(&1))
  #  defp build_transformer([], f_acc), do: f_acc
  #  defp build_transformer([map: f | tail], f_acc) do
  #    wrapped_f = fn {continue, value} ->
  #      if continue, do: {continue, f.(value)}, else: {continue, value}
  #    end
  #    build_transformer(tail, &(f_acc.(wrapped_f.(&1))))
  #  end
  #  defp build_transformer([filter: f | tail], f_acc) do
  #    wrapped_f = fn {continue, value} ->
  #      if continue and f.(value), do: {continue, f.(value)}, else: {false, value}
  #    end
  #    build_transformer(tail, &(f_acc.(wrapped_f.(&1))))
  #  end

end
