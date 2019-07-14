type t = {
  gameId: string,
  role: Player.role,
  player: Player.t,
};

module Decode = {
  let flagsDecoder = json =>
    Json.Decode.{
      gameId: field("game_id", string, json),
      role: field("role", string, json)->Player.stringToRole,
      player: field("player", Player.Decode.playerDecoder, json),
    };

  let flags = flagsDecoder;
};
