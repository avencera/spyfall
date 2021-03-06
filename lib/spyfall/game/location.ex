defmodule Spyfall.Game.Location do
  @type t :: %{id: String.t(), name: String.t()}

  @spec all(integer) :: list(Location.t())
  def all(number_of_locations) do
    all()
    |> Enum.shuffle()
    |> Enum.take(number_of_locations)
  end

  @spec all() :: list(Location.t())
  def all() do
    [
      %{id: "airplane", name: "Airplane"},
      %{id: "bank", name: "Bank"},
      %{id: "beach", name: "Beach"},
      %{id: "cathedral", name: "Cathedral"},
      %{id: "circus_tent", name: "Circus Tent"},
      %{id: "corporate_party", name: "Corporate Party"},
      %{id: "crusader_army", name: "Crusader Army"},
      %{id: "casino", name: "Casino"},
      %{id: "day_spa", name: "Day Spa"},
      %{id: "embassy", name: "Embassy"},
      %{id: "hospital", name: "Hospital"},
      %{id: "hotel", name: "Hotel"},
      %{id: "military_base", name: "Military Base"},
      %{id: "movie_studio", name: "Movie Studio"},
      %{id: "ocean_liner", name: "Ocean Liner"},
      %{id: "passenger_train", name: "Passenger Train"},
      %{id: "pirate_ship", name: "Pirate Ship"},
      %{id: "polar_station", name: "Polar Station"},
      %{id: "police_station", name: "Police Station"},
      %{id: "restaurant", name: "Restaurant"},
      %{id: "school", name: "School"},
      %{id: "service_station", name: "Service Station"},
      %{id: "space_station", name: "Space Station"},
      %{id: "submarine", name: "Submarine"},
      %{id: "supermarket", name: "Supermarket"},
      %{id: "theater", name: "Theater"},
      %{id: "university", name: "University"},
      %{id: "world_war_ii_squad", name: "World War II Squad"},
      %{id: "race_track", name: "Race Track"},
      %{id: "art_museum", name: "Art Museum"},
      %{id: "vineyard", name: "Vineyard"},
      %{id: "baseball_stadium", name: "Baseball Stadium"},
      %{id: "library", name: "Library"},
      %{id: "cat_show", name: "Cat Show"},
      %{id: "retirement_home", name: "Retirement Home"},
      %{id: "jail", name: "Jail"},
      %{id: "construction_site", name: "Construction Site"},
      %{id: "the_united_nations", name: "The United Nations"},
      %{id: "candy_factory", name: "Candy Factory"},
      %{id: "subway", name: "Subway"},
      %{id: "coal_mine", name: "Coal Mine"},
      %{id: "cemetery", name: "Cemetery"},
      %{id: "rock_concert", name: "Rock Concert"},
      %{id: "jazz_club", name: "Jazz Club"},
      %{id: "wedding", name: "Wedding"},
      %{id: "gas_station", name: "Gas Station"},
      %{id: "harbor_docks", name: "Harbor Docks"},
      %{id: "sightseeing_bus", name: "Sightseeing Bus"}
    ]
  end
end
