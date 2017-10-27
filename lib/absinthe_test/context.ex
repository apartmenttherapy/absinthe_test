defmodule AbsintheTest.Context do
  @moduledoc """
  This module provides helper functions for running a query and validating query results.
  """

  alias AbsintheTest.QueryStore

  @doc """
  Runs the specified query against the configured schema with the provided options

  ## Parameters

    - query_name: The query to run against the schema, this query must be registered in the QueryStore
    - options: This can have the same values as the `options` parameter for `Absinthe.run/3`

  ## Examples

      iex> AbsintheTest.Context.run(:event_query, variables: %{"id" => "8"})
      {:ok, %{"data" %{"event" => %{"id" => "8"}}}}

  """
  @spec run_query(atom, Keyword.t) :: Absinthe.run_result
  def run_query(query_name, options \\ []) do
    query_name
    |> fetch_query()
    |> Absinthe.run(schema(), options)
  end

  defp fetch_query(name), do: QueryStore.fetch(name)
  defp schema, do: Application.get_env(:absinthe_test, :schema)

  @doc """
  Register a query for later retrieval

  ## Parameters

    - name: The name that will be used to reference the query
    - query: The `GraphQL` query

  ## Examples

      iex> query = "query event($id: ID, $name: String) { event(id: $id, name: $name) { name } }"
      iex> AbsintheTest.Context.register(:event_query, query)
      :ok

  """
  @spec register_query(atom, String.t) :: :ok
  def register_query(name, query), do: QueryStore.register(name, query)

  @doc """
  Checks the validity of a result when it is expected to be `:ok`

  ## Parameters

    - result: An `Absinthe.run_result` record (probably returned by `Absinthe.run/3`)
    - data_key: A `String.t` value reflecting the part of the data payload to compare against
    - values: A `Map` of attributes that should be present at `data_key` in the response

  ## Examples

      iex> result = AbsintheTest.Context.run(:event_query, variables: %{"id" => "8"})
      iex> AbsintheTest.Runner.expected_result?(result, "event", %{"id" => "8"})
      true

  """
  @spec expected_result?(Absinthe.run_result, String.t, map) :: boolean
  def expected_result?({:ok, %{data: payload}}, data_key, values) do
    payload
    |> Map.get(data_key)
    |> Map.equal?(values)
  end
  def expected_result?({:ok, %{errors: payload}, error_key, values}) do
    payload
    |> Enum.reduce(false, fn error, result ->
         result || Map.get(error, error_key) == values
       end)
  end
  def expected_result?({:error, _}, _data_key, _values), do: false

  @doc """
  Checks the validity of a result when it is expected to be an `:error`

  ## Parameters

    - result: An `Absinthe.run_result` record (probably returned by `Absinthe.run/3`)
    - expected_message: The expected error message

  ## Examples

      iex> result = AbsintheTest.Runner.run(:expensive_query, variables: %{"id" => "8"})
      iex> AbsintheTest.Runner.expected_result?(result, message)
      true

  """
  @spec expected_result?(Absinthe.run_result, String.t) :: boolean
  def expected_result?({:error, received_message}, expected_message) do
    received_message == expected_message
  end
  def expected_result?({:ok, _result}, _), do: false
end
