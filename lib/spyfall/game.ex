defmodule Spyfall.Game do
  alias Spyfall.Game
  alias Spyfall.Game.{Player, Registry}

  # status = :waiting | :in_progress | :ended
  @enforce_keys [:id, :players, :status, :minutes]
  @derive Jason.Encoder
  defstruct [:id, players: [], status: :waiting, minutes: 10]

  def get(%Game{} = game), do: get(game.id)
  def get(game_id), do: Registry.get_game(game_id)

  def create(player, minutes) when is_binary(minutes) do
    create(player, String.to_integer(minutes))
  end

  def create(%Player{} = player, minutes) do
    game_id = generate_game_id()

    with :not_found <- get(game_id),
         game <- %Game{id: game_id, status: :waiting, players: [player], minutes: minutes},
         :ok <- Registry.register_or_replace_game(game) do
      {:ok, game}
    else
      _ ->
        create(player, minutes)
    end
  end

  def start(%Game{} = game) do
    {:ok, %{game | status: :in_progress}}
  end

  def finish(%Game{} = game) do
    {:ok, %{game | status: :ended}}
  end

  def delete(%Game{} = game), do: Registry.delete_game(game)

  def join(game_id, player_name) do
    with {:ok, game} <- get(game_id),
         :waiting <- game.status,
         %Player{} = player <- Player.create(player_name),
         {:ok, game, player} <- add_player(game, player),
         :ok <- Registry.register_or_replace_game(game) do
      {:ok, game, player}
    else
      _ ->
        {:error, "Game does not exist"}
    end
  end

  def add_player(%Game{} = game, %Player{} = player) do
    case game_has_player?(game, player) do
      false -> {:ok, %{game | players: [player | game.players]}, player}
      true -> {:error, "Player is already in the game"}
    end
  end

  def remove_player(%Game{} = game, %Player{} = player) do
    players = Enum.reject(game.players, &(&1.name == player.name))
    {:ok, %{game | players: players}}
  end

  def game_has_player?(game, player) do
    player_ids =
      game
      |> Map.get(:players)
      |> Enum.map(& &1.id)

    player.id in player_ids
  end

  defp generate_game_id() do
    1..4
    |> Enum.map(fn _x -> :rand.uniform(58) end)
    |> Enum.map(&Base58.encode/1)
    |> Enum.join()
    |> binary_part(0, 4)
  end
end
