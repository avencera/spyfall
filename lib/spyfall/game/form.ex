defmodule Spyfall.Game.Form do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field(:name, :string)
    field(:game_id, :string)
    field(:minutes, :integer)
    field(:number_of_locations, :integer)
  end

  def create_changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:name, :minutes, :number_of_locations])
    |> validate_required([:name, :minutes, :number_of_locations])
  end

  def join_changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:name, :game_id])
    |> validate_required([:name, :game_id])
  end
end
