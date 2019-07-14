type status =
  | Waiting
  | InProgress
  | Ended;

type t = {
  id: string,
  minutes: int,
  players: array(Player.t),
  status,
};

let stringToStatus =
  fun
  | "waiting" => Waiting
  | "in_progress" => InProgress
  | "ended" => Ended
  | _ => Ended;

module Decode = {
  let gameDecoder = json =>
    Json.Decode.{
      id: field("id", string, json),
      minutes: field("minutes", int, json),
      status: field("status", string, json)->stringToStatus,
      players: field("players", Player.Decode.players, json),
    };

  let game = gameDecoder;
};
