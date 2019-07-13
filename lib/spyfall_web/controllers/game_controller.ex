defmodule SpyfallWeb.GameController do
  use SpyfallWeb, :controller
  alias Spyfall.Game
  alias Spyfall.Game.Player

  def new(conn, _params) do
    render(conn, "new.html", changeset: Game.Form.create_changeset(%{minutes: 10}))
  end

  def create(conn, %{"form" => params}) do
    with %{valid?: true} <- Game.Form.create_changeset(params),
         %Player{} = player <- Player.create(params["name"]),
         {:ok, %Game{} = game} <- Game.create(player) do
      conn
      |> put_session(:game, game)
      |> put_session(:player, player)
      |> redirect(to: Routes.game_path(conn, :room))
    else
      %{valid?: false} = changeset ->
        render(conn, "new.html", changeset: %{changeset | action: :insert})
    end
  end

  def join_new(conn, %{"id" => game_id}) do
    with {:ok, game, _player} <- session_game_and_player(conn),
         true <- game_id == game.id do
      redirect(conn, to: Routes.game_path(conn, :room))
    else
      _ -> render(conn, "join.html", changeset: Game.Form.join_changeset(%{game_id: game_id}))
    end
  end

  def join_new(conn, _params) do
    case session_game_and_player(conn) do
      {:ok, %Game{}, %Player{}} ->
        redirect(conn, to: Routes.game_path(conn, :room))

      _ ->
        render(conn, "join.html", changeset: Game.Form.join_changeset(%{}))
    end
  end

  def join_create(conn, %{"form" => params}) do
    changeset = Game.Form.join_changeset(params)

    with %{valid?: true} <- changeset,
         {:ok, game, player} <- Game.join(params["game_id"], params["name"]) do
      conn
      |> put_session(:game, game)
      |> put_session(:player, player)
      |> redirect(to: Routes.game_path(conn, :room))
    else
      _error ->
        render(conn, "join.html", changeset: %{changeset | action: :insert})
    end
  end

  def room(conn, _params) do
    with {%Game{} = game, _} <- {get_session(conn, :game), :game},
         {:ok, game} <- Game.get(game.id),
         {%Player{} = player, _} <- {get_session(conn, :player), :player} do
      render(conn, "room.html", player: player, game: game)
    else
      _ -> redirect(conn, to: Routes.page_path(conn, :index))
    end
  end

  defp session_game_and_player(conn) do
    with {%Game{} = game, _} <- {get_session(conn, :game), :game},
         {%Player{} = player, _} <- {get_session(conn, :player), :player} do
      {:ok, game, player}
    else
      _ -> :no_game_or_player
    end
  end
end
