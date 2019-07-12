defmodule Spyfall.Game.Form do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :name, :string
    field :room_id, :string
    field :minutes, :integer
  end

  def create_changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:name, :minutes])
    |> validate_required([:name])
  end

  def join_changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:name, :room_id])
    |> validate_required([:name, :room_id])
  end
end
