defmodule AbsintheTestTest do
  use ExUnit.Case
  doctest AbsintheTest

  test "greets the world" do
    assert AbsintheTest.hello() == :world
  end
end
