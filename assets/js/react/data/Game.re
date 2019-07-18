type status =
  | Waiting
  | InProgress
  | Finished;

type t = {
  id: string,
  minutes: int,
  players: array(Player.t),
  status,
  locations: array(Location.t),
};

let stringToStatus =
  fun
  | "waiting" => Waiting
  | "in_progress" => InProgress
  | "finished" => Finished
  | _ => Finished;

module Decode = {
  let gameDecoder = json =>
    Json.Decode.{
      id: field("id", string, json),
      minutes: field("minutes", int, json),
      status: field("status", string, json)->stringToStatus,
      players: field("players", Player.Decode.players, json),
      locations: field("locations", Location.Decode.locations, json),
    };

  let game = gameDecoder;
};
