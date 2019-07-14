defmodule SpyfallWeb.GameChannel do
  use SpyfallWeb, :channel

  alias Spyfall.Game

  def join("game:" <> game_id, %{"player_id" => player_id}, socket) do
    send(self(), {:send_game, game_id})
    {:ok, assign(socket, :player_id, player_id)}
  end

  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  def handle_in("shout", payload, socket) do
    broadcast(socket, "shout", payload)
    {:noreply, socket}
  end

  def handle_info({:send_game, game_id}, socket) do
    case Game.get(game_id) do
      {:ok, game} -> push(socket, "new_game", game)
      _ -> socket
    end

    {:noreply, socket}
  end
end
