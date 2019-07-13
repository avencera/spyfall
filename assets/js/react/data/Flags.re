type t = {
  game_id: string,
  player: Player.t,
};

module Decode = {
  let flagsDecoder = json =>
    Json.Decode.{
      game_id: field("game_id", string, json),
      player: field("player", Player.Decode.playerDecoder, json),
    };

  let flags = flagsDecoder;
};
