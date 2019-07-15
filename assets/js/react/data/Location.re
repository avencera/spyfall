type t = {
  id: string,
  name: string,
};

module Decode = {
  let locationDecoder = json =>
    Json.Decode.{
      id: field("id", string, json),
      name: field("name", string, json),
    };

  let locations = json => Json.Decode.array(locationDecoder, json);
};
