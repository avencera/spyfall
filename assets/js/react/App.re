type state = {
  game_id: string,
  player: Player.t,
};

let initialState = (flags: Flags.t): state => {
  game_id: flags.game_id,
  player: flags.player,
};

type action =
  | Next;

[@react.component]
let make = (~flags: Js.Json.t) => {
  let lists = Flags.Decode.flags(flags);

  let (state: state, dispatch: action => unit) =
    React.useReducer(
      (state: state, action: action) =>
        switch (action) {
        | Next => state
        },
      initialState(lists),
    );

  <div />;
};
