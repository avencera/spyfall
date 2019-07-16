defmodule Spyfall.Game do
  alias Spyfall.Game
  alias Spyfall.Game.{Player, Location}

  @type t :: %Game{
          pid: pid,
          id: id,
          secret: secret,
          players: list(Player.t()),
          status: status,
          minutes: integer,
          locations: list(Location.t())
        }

  @type id :: String.t()
  @type status :: :waiting | :in_progress | :finished
  @type secret :: %{spy: Player.t(), location: Location.t()}

  @enforce_keys [:id, :players, :status, :minutes, :locations, :secret]
  @derive {Jason.Encoder, only: [:id, :players, :status, :minutes, :locations]}
  defstruct [
    :pid,
    :id,
    :secret,
    players: [],
    status: :waiting,
    minutes: 10,
    locations: [],
    meta: %{}
  ]

  @spec get(Game.t()) :: {:ok, Game.t()} | :not_found
  def get(%Game{} = game), do: get(game.id)

  @spec get(id) :: {:ok, Game.t()} | :not_found
  def get(game_id), do: Game.Server.get_game(game_id)

  @spec create(Player.t(), String.t(), integer) :: {:ok, Game.t()}
  def create(%Player{} = player, minutes, number_of_locations) when is_binary(minutes) do
    create(player, String.to_integer(minutes), number_of_locations)
  end

  @spec create(Player.t(), integer, String.t()) :: {:ok, Game.t()}
  def create(%Player{} = player, minutes, number_of_locations)
      when is_binary(number_of_locations) do
    create(player, minutes, String.to_integer(number_of_locations))
  end

  @spec create(Player.t(), integer, integer) :: {:ok, Game.t()}
  def create(%Player{} = player, minutes, number_of_locations) do
    game_id = generate_game_id()
    locations = Location.all(number_of_locations)

    with :not_found <- get(game_id),
         game <- %Game{
           id: game_id,
           status: :waiting,
           players: [player],
           minutes: minutes,
           locations: locations,
           secret: nil
         } do
      Game.Server.create_game(game)
    else
      _ ->
        create(player, minutes, number_of_locations)
    end
  end

  @spec start(id) :: {:ok, Game.t()} | {:error, String.t()}
  def start(game_id) when is_binary(game_id) do
    case get(game_id) do
      {:ok, game} -> start(game)
      :not_found -> {:error, "Game not found"}
    end
  end

  @spec start(Game.t()) :: {:ok, Game.t()} | {:error, String.t()}
  def start(%Game{} = game) do
    Game.Server.start_game(game)
  end

  @spec finish(Game.t()) :: {:ok, Game.t()} | {:error, String.t()}
  def finish(%Game{} = game) do
    game = %{game | status: :finished}
    Game.Server.update_game(game)
  end

  @spec finish(id) :: {:ok, Game.t()} | {:error, String.t()}
  def finish(game_id) when is_binary(game_id) do
    case get(game_id) do
      {:ok, game} -> finish(game)
      :not_found -> {:error, "Game not found"}
    end
  end

  @spec get_time_left(Game.t()) :: {:ok, integer} | {:error, String.t()}
  def get_time_left(%Game{} = game) do
    case game.meta.started_at do
      nil ->
        {:error, "Not yet started"}

      started_at ->
        secs_since_game_started = System.monotonic_time(:second) - started_at
        time_left = game.minutes * 60 - secs_since_game_started
        {:ok, time_left}
    end
  end

  @spec get_time_left(id) :: {:ok, integer} | {:error, String.t()}
  def get_time_left(game_id) when is_binary(game_id) do
    case get(game_id) do
      {:ok, game} -> get_time_left(game)
      :not_found -> {:error, "Game not found"}
    end
  end

  @spec delete(Game.t()) :: {:ok, Game.t()}
  def delete(%Game{} = game), do: Game.Server.delete_game(game)

  @spec add_player(id, String.t()) :: {:ok, Game.t(), Player.t()} | {:error, String.t()}
  def add_player(game_id, player_name) do
    with {:ok, game} <- get(game_id),
         :waiting <- game.status,
         %Player{} = player <- Player.create(player_name),
         false <- game_has_player?(game, player),
         game <- %{game | players: [player | game.players]},
         {:ok, game} <- Game.Server.update_game(game) do
      {:ok, game, player}
    else
      :in_progress ->
        {:error, "That game is already in progress"}

      :finished ->
        {:error, "That game has already finished"}

      :not_found ->
        {:error, "A game with that ID was not found, please try again"}

      _ ->
        {:error, "Unknown error, please contact us"}
    end
  end

  @spec remove_player(id, String.t()) :: {:ok, Game.t()} | {:error, String.t()}
  def remove_player(game_id, player_id) do
    with {:ok, game} <- get(game_id),
         :waiting <- game.status,
         players <- Enum.reject(game.players, &(&1.id == player_id)),
         game <- %{game | players: players} do
      Game.Server.update_game(game)
    else
      _ ->
        {:error, "Unable to add player"}
    end
  end

  @spec game_has_player?(Game.t(), Player.t()) :: true | false
  def game_has_player?(game, player) do
    player_ids =
      game
      |> Map.get(:players)
      |> Enum.map(& &1.id)

    player.id in player_ids
  end

  @spec generate_game_id() :: id
  defp generate_game_id() do
    1..4
    |> Enum.map(fn _x -> :rand.uniform(58) end)
    |> Enum.map(&Base58.encode/1)
    |> Enum.join()
    |> binary_part(0, 4)
    |> String.upcase()
  end
end
