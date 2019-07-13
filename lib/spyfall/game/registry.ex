defmodule Spyfall.Game.Registry do
  alias Spyfall.Game
  @name __MODULE__

  def dump() do
    GenServer.call(@name, :dump)
  end

  def register_or_replace_game(%Game{} = game) do
    GenServer.cast(@name, {:insert, game.id, game})
  end

  def get_game(game_id) do
    case :ets.lookup(@name, game_id) do
      [{^game_id, %Game{} = game}] -> {:ok, game}
      _ -> :not_found
    end
  end

  def delete_game(game) do
    GenServer.cast(@name, {:delete, game.id})
  end
end