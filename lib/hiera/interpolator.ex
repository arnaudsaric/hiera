defmodule Hiera.Interpolator do
  @moduledoc ~S"""
  Interpolates variables inside data
  """

  defp accumulate("", any) do
    any
  end

  defp accumulate(any, "") do
    any
  end

  defp accumulate(old_acc, new) do
    old_acc_str = if is_binary(old_acc) do
      old_acc
    else
      Kernel.inspect(old_acc)
    end
    new_str = if is_binary(new) do
      new
    else
      Kernel.inspect(new)
    end
    old_acc_str <> new_str
  end

  defp recurse_maybe(var_name, scope, kwlist) do
    if Keyword.get(kwlist, :recurse, false) do
      config = Keyword.get(kwlist, :config)
      stack = Keyword.get(kwlist, :stack)
      if not Enum.member?(stack, var_name) do
        Hiera.Parser.recursive_query(var_name, scope, config, [var_name|stack])
      end
    end
  end

  defp get_var_value(var_name, scope, kwlist) do
    accept_nonexistant = Keyword.get(kwlist, :accept_nonexistant, false)
    with nil <- Map.get(scope, var_name),
         nil <- recurse_maybe(var_name, scope, kwlist),
         nil <- (if accept_nonexistant, do: ""),
    do: :notfound
  end

  def interpolate(any, scope, kwlist \\ [], acc \\ "")

  def interpolate(l, scope, kwlist, _) when is_list(l) do
    for elem <- l do
      interpolate(elem, scope, kwlist)
    end
  end

  def interpolate(%{} = dict, scope, kwlist, _) do
    for {key, value} <- dict, into: %{} do
      {key, interpolate(value, scope, kwlist)}
    end
  end

  def interpolate(str, scope, kwlist, acc) when is_binary(str) do
    case String.split(str, "%{", parts: 2) do
      [^str] -> accumulate(acc, str)
      [beginning, to_split] ->
        [var_name, rest] = String.split(to_split, "}", parts: 2)
        var_value = get_var_value(var_name, scope, kwlist)
        case var_value do
          :notfound -> :notfound
          _ ->
            new_acc = accumulate(acc, beginning) |> accumulate(var_value)
            interpolate(rest, scope, kwlist, new_acc)
        end
    end
  end

  def interpolate(any, _, _, _) do
    any
  end

end
