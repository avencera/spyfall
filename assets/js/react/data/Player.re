type t = {
  id: string,
  name: string,
};

module Decode = {
  let playerDecoder = json =>
    Json.Decode.{
      id: field("id", string, json),
      name: field("name", string, json),
    };

  let players = json => Json.Decode.array(playerDecoder, json);
};
