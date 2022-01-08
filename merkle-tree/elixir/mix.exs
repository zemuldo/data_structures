defmodule App.MixProject do
  use Mix.Project

  def project do
    [
      app: :app,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {App.Application, []},
      extra_applications: [:logger, :runtime_tools, :crypto]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:elixir_uuid, "~> 1.2"},
      {:ex2ms, "~> 1.0"},
      {:jason, "~> 1.2"},
      {:timex, "~> 3.0"},
      {:mix_test_watch, "~> 1.0", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.20", only: [:docs, :dev], runtime: false},
    ]
  end
end
