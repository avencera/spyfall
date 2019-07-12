defmodule Spyfall.Application do
  @moduledoc false
  use Application

  def start(_type, _args) do
    children = [
      SpyfallWeb.Endpoint,
      Supervisor.child_spec({DistributedKV, Spyfall.Game.Registry}, id: :game_registry)
    ]

    opts = [strategy: :one_for_one, name: Spyfall.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    SpyfallWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
