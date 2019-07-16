defmodule Spyfall.Game.Server do
  use GenServer

  alias Spyfall.Game
  @registry Spyfall.Game.Registry

  @impl true
  def init(%Game{} = game) do
    {:ok, game}
  end

  def get_game(game_id) do
    game_id = String.upcase(game_id)

    case :ets.lookup(@registry, game_id) do
      [{^game_id, %Game{} = game}] -> {:ok, game}
      _ -> :not_found
    end
  end

  def dump() do
    GenServer.call(@registry, :dump)
  end

  def create_game(%Game{} = game) do
    game_id = String.upcase(game.id)
    game = %{game | id: game_id}

    case GenServer.start(__MODULE__, game) do
      {:ok, pid} ->
        game = %{game | pid: pid}
        GenServer.cast(@registry, {:insert, game_id, game})

        {:ok, game}

      _ ->
        {:error, "Unable to create game server"}
    end
  end

  def start_game(%Game{status: :in_progress} = game), do: {:ok, game}
  def start_game(%Game{status: :finished} = game), do: {:ok, game}

  def start_game(game) do
    game_id = String.upcase(game.id)

    meta = Map.put(game.meta, :started_at, System.monotonic_time(:second))

    spy = Enum.random(game.players)
    secret = %{spy: spy, location: Enum.random(game.locations)}

    game = %{
      game
      | status: :in_progress,
        players: Enum.shuffle(game.players),
        meta: meta,
        secret: secret
    }

    GenServer.cast(@registry, {:insert, game_id, game})
    schedule_clean_up(game)

    {:ok, game}
  end

  def update_game(%Game{} = game) do
    game_id = String.upcase(game.id)
    GenServer.cast(@registry, {:insert, game_id, game})
    {:ok, game}
  end

  def delete_game(game) do
    game_id = String.upcase(game.id)

    # delete game from registry
    GenServer.cast(@registry, {:delete, game_id})

    # shutdown genserver
    GenServer.stop(game.pid, :normal)

    {:ok, game}
  end

  defp schedule_clean_up(game) do
    # perform clean up 15 minutes after game ends
    # should run incase the users don't manually delete the game

    clean_up_after = :timer.minutes(game.minutes + 15)
    Process.send_after(game.pid, :clean_up, clean_up_after)
  end

  @impl true
  def handle_info(:clean_up, game) do
    IO.inspect(game, label: "RUNNING CLEAN UP FOR GAME")

    # delete game from registry
    game_id = String.upcase(game.id)
    GenServer.cast(@registry, {:delete, game_id})

    {:stop, :normal, game}
  end

  @impl true
  def terminate(_reason, game) do
    # delete game from registry
    GenServer.cast(@registry, {:delete, game.id})
  end
end
