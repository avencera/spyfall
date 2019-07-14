open Json.Decode;

let optionalField =
    (fieldName: string, type_: decoder('a)): decoder(option('a)) =>
  optional(field(fieldName, type_));
