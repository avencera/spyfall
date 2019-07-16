type t = {
  gameId: string,
  player: Player.t,
};

module Decode = {
  let flagsDecoder = json =>
    Json.Decode.{
      gameId: field("game_id", string, json),
      player: field("player", Player.Decode.playerDecoder, json),
    };

  let flags = flagsDecoder;
};
