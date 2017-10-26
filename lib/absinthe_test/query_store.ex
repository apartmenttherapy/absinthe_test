defmodule AbsintheTest.QueryStore do
  use GenServer

  @doc """
  Returns the query stored under the given name

  ## Parameters

    - name: The name assigned to the stored query

  ## Examples

      iex> AbsintheTest.QueryStore.fetch(:event_query)
      "query event($id: ID!) { event(id: $id) { name } }"

  """
  @spec fetch(atom) :: String.t | nil
  def fetch(name), do: GenServer.call(__MODULE__, {:fetch, name})

  @doc """
  Registers a query under the given name

  ## Parameters

    - name: The name that should be associated with the query
    - query: The string representing the GraphQL query

  ## Examples

      iex> query = "query event($id: ID!) { event(id: $id) { name } }"
      iex> AbsintheTest.QueryStore.register(:event_query, query)
      :ok

  """
  @spec register(atom, String.t) :: :ok
  def register(name, query), do: GenServer.call(__MODULE__, {:register, {name, query}})

  def start_link, do: GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  def init, do: {:ok, %{}}

  def handle_call({:fetch, name}, _from, state) do
    {:reply, Map.get(state, name), state}
  end

  def handle_call({:register, {name, query}}, _from, state) do
    new_state =
      state
      |> Map.put(name, query)

    {:reply, :ok, new_state}
  end
end
