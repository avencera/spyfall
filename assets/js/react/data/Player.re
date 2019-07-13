type role =
  | Member
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
  | _ => Member;

module Decode = {
  let playerDecoder = json =>
    Json.Decode.{
      id: field("id", string, json),
      name: field("name", string, json),
      role: field("role", string, json)->stringToRole,
    };
};
