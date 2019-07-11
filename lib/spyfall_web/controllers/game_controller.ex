defmodule SpyfallWeb.GameController do
  use SpyfallWeb, :controller
  alias Spyfall.Game

  def new(conn, _params) do
    render(conn, "new.html", changeset: Game.Form.changeset(%{minutes: 10}))
  end

  def create(conn, %{"form" => params}) do
    case Game.Form.changeset(params) do
      %{valid?: true} ->
        conn
        |> put_flash(:info, "Product created successfully.")
        |> redirect(to: Routes.page_path(conn, :index))

     %{valid?: false} = changeset ->
        IO.inspect(changeset)
        render(conn, "new.html", changeset: %{changeset | action: :insert})
    end
  end
end
