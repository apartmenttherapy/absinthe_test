defmodule AbsintheTest.Mixfile do
  use Mix.Project

  def project do
    [
      app: :absinthe_test,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      elixirc_paths: elixirc_paths(Mix.env),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test),      do: ["lib", "test/support"]
  defp elixirc_paths(_),          do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:absinthe, ">= 0.0.0"}
    ]
  end
end
