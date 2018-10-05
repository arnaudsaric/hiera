defmodule Hiera.Config do

  defp get_backend(mode) do
    Macro.expand_once({
      :__aliases__,
      [alias: false],
      [:Hiera, :Backend, String.capitalize(mode) |> String.to_atom]
    }, __ENV__)  
  end

  def read_config(path) do
    backend = get_backend "yaml"
    backend.parse_path(path, %{})
  end

  defp fill_backend(hierarchy_element) do
    backend_str = with nil <- Map.get(hierarchy_element, "data_hash"),
      nil <- Map.get(hierarchy_element, "lookup_key"),
      nil <- Map.get(hierarchy_element, "backend"),
      do: nil
    Map.put(hierarchy_element, :backend, get_backend backend_str)
  end

  defp resolve_paths("path", path, scope, datadir) do
    case Hiera.Interpolator.interpolate(path, scope) do
      :notfound -> []
      resolved -> [Path.join(datadir, resolved)]
    end
  end

  defp resolve_paths("paths", paths, scope, datadir) do
    Hiera.Interpolator.interpolate(paths, scope)
    |> Enum.filter_map(&(&1 != :notfound), &(Path.join(datadir, &1)))
  end

  defp resolve_paths("glob", path, scope, datadir) do
    resolve_paths("path", path, scope, datadir)
    |> Enum.flat_map(&Path.wildcard/1)
  end

  defp resolve_paths("globs", paths, scope, datadir) do
    resolve_paths("paths", paths, scope, datadir)
    |> Enum.flat_map(&Path.wildcard/1)
  end

  defp resolve_paths("mapped_paths", [array_name, tmp_var, path], scope, datadir) do
    Map.get(scope, array_name, [])
    |> Enum.reduce([], fn el, acc ->
      tmp_scope = Map.put(scope, tmp_var, el)
      case Hiera.Interpolator.interpolate(path, tmp_scope) do
        :notfound -> acc
        resolved -> [Path.join(datadir, resolved) | acc]
      end end)
    |> Enum.reverse()
  end

  defp fill_paths(e, s, keys\\["path","paths","glob","globs","mapped_paths"])

  defp fill_paths(_hierarchy_element, _scope, []) do
    []
  end
  
  defp fill_paths(hierarchy_element, scope, [head | tail]) do
    paths = Map.get(hierarchy_element, head)
    if not is_nil(paths) do
      datadir = Map.get(hierarchy_element, "datadir", "")
      resolve_paths(head, paths, scope, datadir)
      |> Enum.map(&(Map.put(hierarchy_element, :path, &1)))
    else
      fill_paths(hierarchy_element, scope, tail)
    end
  end

  def hierarchy(config, scope) do
    Map.get(config, "hierarchy", [])
    |> Enum.reduce([], fn el, acc ->
      new_els = Map.get(config, "defaults", %{})
                |> Map.merge(el)
                |> fill_backend()
                |> fill_paths(scope)
      acc ++ new_els end)
  end

end
