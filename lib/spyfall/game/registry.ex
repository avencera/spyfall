defmodule Spyfall.Game.Registry do
  alias Spyfall.Game
  @name __MODULE__

  def dump() do
    GenServer.call(@name, :dump)
  end

  def register_or_replace_game(%Game{} = game) do
    game_id = String.upcase(game.id)
    GenServer.cast(@name, {:insert, game_id, game})
  end

  def get_game(game_id) do
    game_id = String.upcase(game_id)

    case :ets.lookup(@name, game_id) do
      [{^game_id, %Game{} = game}] -> {:ok, game}
      _ -> :not_found
    end
  end

  def delete_game(game) do
    game_id = String.upcase(game.id)
    GenServer.cast(@name, {:delete, game_id})
  end
end
