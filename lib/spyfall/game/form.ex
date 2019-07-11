defmodule Spyfall.Game.Form do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :name, :string
    field :minutes, :integer
  end

  @required_fields [:name]
  @optional_fields [:minutes]

  def changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
