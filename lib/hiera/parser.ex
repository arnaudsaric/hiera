defmodule Hiera.Parser do

  use GenServer

  #Client

  def start_link(config) do
    GenServer.start_link(__MODULE__, config, [])
  end

  def lookup(server, name, input_vars) do
    GenServer.call(server, {:lookup, name, input_vars, :simple})
  end

  def lookup(server, name, input_vars, mode) do
    GenServer.call(server, {:lookup, name, input_vars, mode})
  end

  #Helpers
  defp capitalize(atom) do
    atom
    |> Atom.to_string
    |> String.capitalize
    |> String.to_atom
  end

  defp get_lookup_method(mode) do
    Macro.expand_once({
      :__aliases__,
      [alias: false],
      [:Hiera, :LookupMethod, capitalize mode]
    }, __ENV__)  
  end

  #Server
  def init(config_file) do
    config = Hiera.Config.read_config config_file
    {:ok, config}
  end

  defp lookup_element(hierarchy_element, acc, name, scope, mode, config, stack) do
    options = Map.get(hierarchy_element, "options", %{})
    backend = hierarchy_element.backend
    {found, raw_result} = backend.lookup_path(hierarchy_element.path,
                                              name,
                                              options)
    result = if found do
      Hiera.Interpolator.interpolate(raw_result,
                                     scope,
                                     accept_nonexistant: true,
                                     recurse: true,
                                     config: config,
                                     stack: stack)
    end
    mode.reducer({found, result}, acc)
  end

  defp lookup_hierarchy(name, scope, mode, config, stack\\[]) do
    {_, r} = Enumerable.reduce(Hiera.Config.hierarchy(config, scope),
                 {:cont, mode.init_acc()},
                 &(lookup_element(&1, &2, name, scope, mode, config, stack)))
    r
  end

  def handle_call({:lookup, name, scope, mode}, _from, config) do
    mode_module = get_lookup_method(mode)
    {:reply, lookup_hierarchy(name, scope, mode_module, config), config}
  end

  def recursive_query(name, scope, config, stack) do
    mode = get_lookup_method(:simple)
    lookup_hierarchy(name, scope, mode, config, stack)
  end
end
