defmodule Spyfall.Game.Player do
  alias Spyfall.Game.Player

  # role = :member | :spy
  @enforce_keys [:id, :name, :role]
  defstruct [:id, :name, role: :member]

  def create(name) do
    %Player{id: generate_player_id(), name: name, role: :member}
  end

  defp generate_player_id() do
    :crypto.strong_rand_bytes(16)
    |> Base.url_encode64()
    |> binary_part(0, 16)
  end
end
