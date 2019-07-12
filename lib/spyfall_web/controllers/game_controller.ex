defmodule SpyfallWeb.GameController do
  use SpyfallWeb, :controller
  alias Spyfall.Game

  def new(conn, _params) do
    render(conn, "new.html", changeset: Game.Form.create_changeset(%{minutes: 10}))
  end

  def join_new(conn, %{"id" => room_id}) do
    render(conn, "join.html", changeset: Game.Form.join_changeset(%{room_id: room_id}))
  end

  def join_new(conn, _params) do
    render(conn, "join.html", changeset: Game.Form.join_changeset(%{}))
  end

  def create(conn, %{"form" => params}) do
    case Game.Form.create_changeset(params) do
      %{valid?: true} ->
        conn
        |> put_flash(:info, "Product created successfully.")
        |> redirect(to: Routes.page_path(conn, :index))

     %{valid?: false} = changeset ->
        render(conn, "new.html", changeset: %{changeset | action: :insert})
    end
  end


  def join_create(conn, %{"form" => params}) do
    case Game.Form.join_changeset(params) do
      %{valid?: true} ->
        conn
        |> redirect(to: Routes.game_path(conn, :room))

     %{valid?: false} = changeset ->
        render(conn, "join.html", changeset: %{changeset | action: :insert})
    end
  end

  def room(conn, %{"id" => room_id}) do
    render(conn, "room.html", room_id: room_id)
  end
end
