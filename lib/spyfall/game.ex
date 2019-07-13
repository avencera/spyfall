defmodule Spyfall.Game do
  alias Spyfall.Game
  alias Spyfall.Game.{Player, Registry}

  # state = :waiting | :in_progress | :ended
  @enforce_keys [:game_id, :state]
  defstruct [:game_id, players: [], state: :waiting]

  def create(%Player{} = player) do
    game_id = generate_game_id()

    case Registry.get_game(game_id) do
      :not_found -> {:ok, %Game{game_id: game_id, state: :waiting, players: [player]}}
      {:ok, _game} -> create(player)
    end
  end

  def join(game_id, player_name) do
    case Registry.get_game(game_id) do
      {:ok, game} ->
        player = Player.create(player_name)
        add_player(game, player)

      :not_found ->
        {:error, "Game does not exist"}
    end
  end

  def start(%Game{} = game) do
    {:ok, %{game | state: :in_progress}}
  end

  def finish(%Game{} = game) do
    {:ok, %{game | state: :ended}}
  end

  def add_player(%Game{} = game, %Player{} = player) do
    case game_has_player?(game, player) do
      false -> {:ok, %{game | players: [player | game.players]}}
      true -> {:error, "Player is already in the game"}
    end
  end

  def remove_player(%Game{} = game, %Player{} = player) do
    players = Enum.reject(game.players, &(&1.name == player.name))
    {:ok, %{game | players: players}}
  end

  def can_player_enter_game_room?(game, player) do
    with {:ok, game} <- Registry.get_game(game.id),
         true <- game_has_player?(game, player) do
      true
    else
      _ ->
        false
    end
  end

  defp game_has_player?(game, player) do
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
