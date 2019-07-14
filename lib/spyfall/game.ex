defmodule Spyfall.Game do
  alias Spyfall.Game
  alias Spyfall.Game.{Player, Registry}

  # status = :waiting | :in_progress | :finished
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

  def start(%Game{} = game), do: {:ok, %{game | status: :in_progress}}

  def start(game_id) when is_binary(game_id) do
    case get(game_id) do
      {:ok, game} -> start(game)
      :not_found -> {:error, "Game not found"}
    end
  end

  def finish(%Game{} = game), do: {:ok, %{game | status: :finished}}

  def finish(game_id) when is_binary(game_id) do
    case get(game_id) do
      {:ok, game} -> finish(game)
      :not_found -> {:error, "Game not found"}
    end
  end

  def delete(%Game{} = game), do: Registry.delete_game(game)

  def add_player(game_id, player_name) do
    with {:ok, game} <- get(game_id),
         :waiting <- game.status,
         %Player{} = player <- Player.create(player_name),
         false <- game_has_player?(game, player),
         game <- %{game | players: [player | game.players]},
         :ok <- Registry.register_or_replace_game(game) do
      {:ok, game, player}
    else
      _ ->
        {:error, "Unable to add player"}
    end
  end

  def remove_player(game_id, player_id) do
    with {:ok, game} <- get(game_id),
         :waiting <- game.status,
         players <- Enum.reject(game.players, &(&1.id == player_id)),
         game <- %{game | players: players},
         :ok <- Registry.register_or_replace_game(game) do
      {:ok, game}
    else
      _ ->
        {:error, "Unable to add player"}
    end
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
    |> String.upcase()
  end
end
