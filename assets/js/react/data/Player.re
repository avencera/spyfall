type role =
  | Member
  | Unknown
  | Spy;

type t = {
  id: string,
  name: string,
  role,
};

let stringToRole =
  fun
  | "spy" => Spy
  | "memeber" => Member
  | _ => Unknown;

module Decode = {
  let playerDecoder = json =>
    Json.Decode.{
      id: field("id", string, json),
      name: field("name", string, json),
      role:
        Decode.optionalField("role", string, json)
        ->Belt.Option.getWithDefault("secret")
        ->stringToRole,
    };

  let players = json => Json.Decode.array(playerDecoder, json);
};
