defmodule AbsintheTest.ContextTest do
  use ExUnit.Case

  alias AbsintheTest.Context
  alias AbsintheTest.QueryStore

  describe "querying" do
    setup do
      query = """
      query test($value: Int) {
        test(value: $value) {
          value
        }
      }
      """

      QueryStore.register(:test_query, query)
    end

    test "run_query/2 returns the `Absinthe.run_result` of the specified query" do
      assert {:ok, %{data: _payload}} = Context.run_query(:test_query)
    end

    test "run_query/2 applies the given variables to the query" do
      assert {:ok, %{data: %{"test" => %{"value" => 8}}}} = Context.run_query(:test_query, variables: %{"value" => 8})
    end
  end

  describe "query registration" do
    test "register_query/2 registers the given query with the QueryStore" do
      assert :ok = Context.register_query(:new_query, "query {}")
    end
  end

  describe "result validation" do
    test "expected_result?/3 returns true if the result is an `:ok` and has the given values at the given key" do
      assert Context.expected_result?(ok_result(), "payload", %{"value" => true})
    end

    test "expected_result?/3 returns false if the result is an `:ok` doesn't have the requested data" do
      refute Context.expected_result?(ok_result(), "payload", %{"value" => false})
    end

    test "expected_result?/3 returns false if the result is an `:error`" do
      refute Context.expected_result?(error_result(), "payload", %{"value" => true})
    end

    test "expected_result?/2 returns true if the result is an `:error` and has the given message" do
      assert Context.expected_result?(error_result(), "It broke")
    end

    test "expected_result?/2 returns false if the result is an `:error` but the message doesn't exist" do
      refute Context.expected_result?(error_result(), "Too Complex")
    end

    test "expected_result?/2 returns false if the result is an `:ok`" do
      refute Context.expected_result?(ok_result(), "It broke")
    end

    def ok_result, do: {:ok, %{data: %{"payload" => %{"value" => true}}}}
    def error_result, do: {:error, "It broke"}
  end
end
