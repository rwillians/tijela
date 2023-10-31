defmodule Cumbuca.MixProject do
  use Mix.Project

  def project do
    [
      app: :tijela,
      version: "0.1.0",
      elixir: "~> 1.15",
      elixirc_paths: elixirc_paths(Mix.env()),
      elixirc_options: [debug_info: Mix.env() == :dev],
      build_embedded: Mix.env() not in [:dev, :test],
      start_permanent: Mix.env() not in [:dev, :test],
      aliases: aliases(),
      deps: deps()
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
    ]
  end

  def application do
    [
      mod: {Tijela, []},
      extra_applications: [:logger, :runtime_tools, :os_mon]
    ]
  end

  defp deps do
    [
      {:bookk, "~> 0.1.2"},
      {:credo, "~> 1.7.0", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4.2", only: [:dev, :test], runtime: false},
      {:ecto_sql, "~> 3.10.2"},
      {:jason, "~> 1.4.1"},
      {:postgrex, "~> 0.17.3"}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
