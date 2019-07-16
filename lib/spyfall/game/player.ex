defmodule Spyfall.Game.Player do
  alias Spyfall.Game.Player

  @derive {Jason.Encoder, only: [:id, :name]}
  @enforce_keys [:id, :name]
  defstruct [:id, :name]

  def create(name) do
    %Player{id: generate_player_id(), name: name}
  end

  defp generate_player_id() do
    :crypto.strong_rand_bytes(16)
    |> Base.url_encode64()
    |> binary_part(0, 16)
  end
end
