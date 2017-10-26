defmodule AbsintheTest.TestSchema do
  use Absinthe.Schema

  object :test_result do
    field :value, :integer
  end

  query do
    field :test, :test_result do
      arg :value, :integer

      resolve fn args, _context ->
        {:ok, %{value: Map.get(args, :value)}}
      end
    end
  end
end
