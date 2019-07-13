defmodule SpyfallWeb.PageView do
  use SpyfallWeb, :view

  def index_button_class(true, _), do: "gray-button-outline"
  def index_button_class(false, "new"), do: "indigo-button mr-1"
  def index_button_class(false, "edit"), do: "indigo-button-outline"
end
