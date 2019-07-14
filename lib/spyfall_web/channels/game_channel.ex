defmodule SpyfallWeb.GameChannel do
  use SpyfallWeb, :channel

  def join("game:" <> game_id, payload, socket) do
    IO.inspect(payload, label: "PAYLOAD")
    {:ok, socket}
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (room:lobby).
  def handle_in("shout", payload, socket) do
    broadcast(socket, "shout", payload)
    {:noreply, socket}
  end
end
