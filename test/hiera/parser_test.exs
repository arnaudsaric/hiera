defmodule Hiera.ParserTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, server} = get_fixture("hiera") |> Hiera.Parser.start_link
    {:ok, server: server}
  end

  test "can do non-interpolated simple lookup", %{server: server} do
    input_vars = %{"hostname" => "foo.domain", "osfamily" => "RedHat"}
    assert Hiera.Parser.lookup(server, "a", input_vars) == 2
    assert Hiera.Parser.lookup(server, "b", input_vars) == 3
    assert Hiera.Parser.lookup(server, "c", input_vars) == 6
    assert Hiera.Parser.lookup(server, "d", input_vars) == 6
    input_vars = %{"hostname" => "bar.domain", "osfamily" => "Ubuntu"}
    assert Hiera.Parser.lookup(server, "a", input_vars) == 1
    assert Hiera.Parser.lookup(server, "b", input_vars) == 1
    assert Hiera.Parser.lookup(server, "c", input_vars) == 1
    assert is_nil(Hiera.Parser.lookup(server, "d", input_vars))
  end

  test "can do interpolated simple lookup", %{server: server} do
    input_vars = %{"hostname" => "foo.domain", "osfamily" => "RedHat"}
    assert Hiera.Parser.lookup(server, "e", input_vars) == 6
    assert Hiera.Parser.lookup(server, "f", input_vars) == "foo.domain"
    assert Hiera.Parser.lookup(server, "g", input_vars) == "23.txt"
  end

  test "can lookup arrays", %{server: server} do
    input_vars = %{"hostname" => "foo.domain", "osfamily" => "RedHat"}
    assert Hiera.Parser.lookup(server, "arraya", input_vars) == [4, 5]
    assert Hiera.Parser.lookup(server, "arraya", input_vars, :array) == [4, 5, 1, 2, 3]
    assert Hiera.Parser.lookup(server, "arrayb", input_vars, :array) == [6, 2]
  end

  test "can lookup hashes", %{server: server} do
    input_vars = %{"hostname" => "foo.domain", "osfamily" => "RedHat"}
    expected_simple = %{"toto" => 51, "fritz" => 27}
    assert Hiera.Parser.lookup(server, "hasha", input_vars) == expected_simple
    expected_merged = %{"toto" => 51, "fritz" => 27, "titi" => "foo.domain"}
    assert Hiera.Parser.lookup(server, "hasha", input_vars, :hash) == expected_merged
  end

  test "can handle bad or missing facts", %{server: server} do
    input_vars = %{"hostname" => "foo.domain", "osfamily" => "Solaris"}
    assert Hiera.Parser.lookup(server, "a", input_vars) == 2
    assert Hiera.Parser.lookup(server, "b", input_vars) == 5
    assert Hiera.Parser.lookup(server, "c", input_vars) == 6
    assert is_nil(Hiera.Parser.lookup(server, "d", input_vars))
    input_vars = %{"hostname" => "foo.domain"}
    assert Hiera.Parser.lookup(server, "a", input_vars) == 2
    assert Hiera.Parser.lookup(server, "b", input_vars) == 5
    assert Hiera.Parser.lookup(server, "c", input_vars) == 6
    assert is_nil(Hiera.Parser.lookup(server, "d", input_vars))
  end

  test "can handle interpolation loops", %{server: server} do
    input_vars = %{"hostname" => "foo.domain", "osfamily" => "RedHat"}
    assert Hiera.Parser.lookup(server, "h", input_vars) == ""
  end

  test "can handle mapped paths", %{server: server} do
    input_vars = %{"topclasses" => ["a", "b", "c"], "osfamily" => "RedHat"}
    assert Hiera.Parser.lookup(server, "mpa", input_vars) == 3
    assert Hiera.Parser.lookup(server, "mpb", input_vars) == 5
    assert Hiera.Parser.lookup(server, "mpc", input_vars, :array) == [0, 9]
  end

  defp get_fixture(name) do
    Path.join(File.cwd!(), "test/fixtures/#{name}.yaml")
  end
end

