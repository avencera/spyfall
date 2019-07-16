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

  def handle_in("start_game", _, socket) do
    case Game.start(socket.assigns.game_id) do
      {:ok, new_game} -> broadcast(socket, "new_game", new_game)
      _ -> :nothing
    end

    {:noreply, socket}
  end

  def handle_in("timer_ended", _, socket) do
    with {:ok, time_left} when time_left <= 0 <- Game.get_time_left(socket.assigns.game_id),
         {:ok, new_game} <- Game.finish(socket.assigns.game_id) do
      broadcast(socket, "new_game", new_game)
    end

    {:noreply, socket}
  end

  def handle_in("get_secret", _, socket) do
    player_id = socket.assigns.player_id
    game_id = socket.assigns.game_id

    case Game.get(game_id) do
      {:ok, game} ->
        if game.secret.spy.id == player_id do
          push(socket, "received_secret:spy", %{})
        else
          push(socket, "received_secret:location", %{location: game.secret.location.name})
        end

      _ ->
        :nothing
    end

    {:noreply, socket}
  end

  def handle_in("get_time_left", _, socket) do
    case Game.get_time_left(socket.assigns.game_id) do
      {:ok, time_left} when time_left <= 0 ->
        broadcast(socket, "received_time_left", %{time_left: 0})
        handle_in("timer_ended", :nothing, socket)

      {:ok, time_left} ->
        broadcast(socket, "received_time_left", %{time_left: time_left})

      _ ->
        :nothing
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
