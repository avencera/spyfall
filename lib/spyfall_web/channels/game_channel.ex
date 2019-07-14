defmodule SpyfallWeb.GameChannel do
  use SpyfallWeb, :channel

  alias Spyfall.Game

  def join("game:" <> game_id, %{"player_id" => player_id}, socket) do
    send(self(), {:send_game, game_id})

    socket =
      socket
      |> assign(:player_id, player_id)
      |> assign(:game_id, game_id)

    {:ok, socket}
  end

  def handle_in("remove_player", %{"player_id" => player_id}, socket) do
    case Game.remove_player(socket.assigns.game_id, player_id) do
      {:ok, new_game} -> broadcast(socket, "new_game", new_game)
      _ -> :nothing
    end

    {:noreply, socket}
  end

  def handle_info({:send_game, game_id}, socket) do
    case Game.get(game_id) do
      {:ok, game} -> broadcast(socket, "new_game", game)
      _ -> socket
    end

    {:noreply, socket}
  end
end
