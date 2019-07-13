defmodule SpyfallWeb.LayoutView do
  use SpyfallWeb, :view
  alias Spyfall.Toastr

  def flash_messages(conn) do
    flashes = get_flash(conn)

    flashes
    |> Map.keys()
    |> Enum.map(fn key -> Toastr.make_msg(key, flashes[key]) end)
  end
end
