defmodule Hiera.LookupMethod do
  @callback init_acc() :: any
  @callback reducer(any, any) :: any
end
