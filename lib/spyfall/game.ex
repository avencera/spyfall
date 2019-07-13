defmodule Spyfall.Game do
  alias Spyfall.Game
  alias Spyfall.Game.{Player, Registry}

  # state = :waiting | :in_progress | :ended
  @enforce_keys [:game_id, :state]
  defstruct [:game_id, players: [], state: :waiting]

  def create_game(game_id, %Player{}) do
    {:ok, %Game{game_id: game_id, state: :waiting, players: [player]}}
  end

  def join_game(game_id, player_name) do
    player = %Player{name: player_name}
    add_player(game, player)
  end

  def start_game(%Game{} = game) do
    {:ok, %{game | state: :in_progress} }
  end

  def end_game(%Game{} = game) do
    {:ok, %{game | state: :ended }}
  end

  def add_player(%Game{} = game, %Player{} = player) do
    players = Enum.uniq_by([ player | game.players ], & &1.name)
    {:ok, %{game | players: players}}
  end

  def remove_player(%Game{} = game, %Player{} = player) do
    players = Enum.reject(game.players, & &.name == player.name)
    {:ok, %{game | players: players}}
  end

  defp generate_game_id() do
    1..4
    |> Enum.map(fn _x -> :rand.uniform(58) end)
    |> Enum.map(&Base58.encode/1)
    |> Enum.join()
    |> binary_part(0, 4)
  end
end
