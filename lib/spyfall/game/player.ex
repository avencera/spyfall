defmodule Spyfall.Game.Player do
  alias Spyfall.Game.Player

  @type t :: %Player{id: String.t(), name: String.t()}
  @type id :: String.t()

  @derive {Jason.Encoder, only: [:id, :name]}
  @enforce_keys [:id, :name]
  defstruct [:id, :name]

  @spec create(id) :: Player.t()
  def create(name) do
    %Player{id: generate_player_id(), name: name}
  end

  @spec generate_player_id() :: id
  defp generate_player_id() do
    :crypto.strong_rand_bytes(16)
    |> Base.url_encode64()
    |> binary_part(0, 16)
  end
end
