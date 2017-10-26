defmodule AbsintheTest do
  @moduledoc """
  The AbsintheTest Application module, this provides a supervisor/starting point for the QueryStore during tests.
  """

  use Application

  alias AbsintheTest.QueryStore

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(QueryStore, [])
    ]

    opts = [strategy: :one_for_one, name: AbsintheTest.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
