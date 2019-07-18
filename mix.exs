defmodule Spyfall.MixProject do
  use Mix.Project

  def project do
    [
      app: :spyfall,
      version: "0.1.0",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      releases: releases(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      mod: {Spyfall.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  def releases() do
    [
      spyfall: [
        include_executables_for: [:unix],
        applications: [runtime_tools: :permanent]
      ]
    ]
  end

  defp deps do
    [
      {:phoenix_ecto, "~> 4.0"},
      {:base58, "~> 0.1.0"},
      {:phoenix, "~> 1.4.9"},
      {:libcluster, "~> 3.1"},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
      {:phoenix_pubsub, "~> 1.1"},
      {:distributed_kv, github: "avencera/distributed_kv"},
      {:phoenix_live_view, github: "phoenixframework/phoenix_live_view"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"}
    ]
  end
end
