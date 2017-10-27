# AbsintheTest

A Small library to help test your Absinthe Schema.  This provides a centralized way to save queries and helper functions for running those queries and also for verifying the results of those queries.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `absinthe_test` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:absinthe_test, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/absinthe_test](https://hexdocs.pm/absinthe_test).

## Usage

### Configuration

You will need to tell `AbsintheTest` what module your Schema lives in.  To do this simply set the `schema` configuration to the name of your module:

```elixir
  # test.exs
  
  config :absinthe_test, schema: My.Schema.Module
```

### Startup

You will also need to start `AbsintheTest` before you use it (there is a small genserver which manages query storage for you)

```elixir
# test_helper.exs

AbsintheTest.start([], [])
```

### Writing Tests

To test your schema you will need to do three things:

1) register queries
2) execute queries
3) verify results

The examples below will use the following **Schema**:

```elixir
query do
  field :test, :test do
    arg :value
    
    resolve fn args, _ ->
      {:ok, %{value: Map.get(args, :value)}}
    end
  end
end
```

#### Registering A Query

```elixir
query = """
query testQuery($id: ID!, $value: Int) {
  testQuery(id: $id, value: $value) {
    id
    value
  }
}
"""

AbsintheTest.Context.register_query(:test_query, query)
```

#### Executing a Query

```elixir
result = AbsintheTest.Context.run_query(:test_query, variables: %{"value" => 4})
```

#### Verifying Results

```elixir
true = AbsintheTest.expected_result?(result, "test", %{"value" => 4})
```

The `expected_result?` function has two forms `/3` and `/2`.  The `/3` form will validate assuming an `{:ok, Absinthe.run_result}` form.  You can check for a specific key/value pair in the response payload with that form.  The `/2` form will validate assuming an `{:error, String.t}` form.

```elixir
iex> {:ok, %{data: %{"test" => %{"value" => 5}}}}
iex> |> AbsintheTest.Context.expected_result?("test", %{"value" => 5})
true

iex> {:ok, %{data: %{"test" => %{"id" => 84}}}}
iex> |> AbsintheTest.Context.expected_result?("test", %{"value" => 22})
false

iex> {:error, "Soylent Green is People"}
iex> |> AbsintheTest.Context.expected_result?("hungerLevel", %{"value" => 0})
false

iex> {:error, "Soylent Green is People"}
iex> |> AbsintheTest.Context.expected_result?("Soylent Green is People")
true
```
