defmodule SpyfallWeb.PageController do
  use SpyfallWeb, :controller
  alias Spyfall.Game
  alias Spyfall.Game.Player

  def index(conn, _params) do
    with {%Game{} = game, _} <- {get_session(conn, :game), :game},
         {:ok, game} <- Game.get(game.id),
         {%Player{} = player, _} <- {get_session(conn, :player), :player},
         true <- Game.game_has_player?(game, player) do
      render(conn, "index.html", in_game?: true)
    else
      _ ->
        render(conn, "index.html", in_game?: false)
    end
  end
end
