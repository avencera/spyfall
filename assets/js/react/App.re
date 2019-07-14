type state = {
  gameId: string,
  player: Player.t,
};

let initialState = (flags: Flags.t): state => {
  gameId: flags.gameId,
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

  React.useEffect1(
    () => {
      Phoenix.joinChannel(state.gameId, state.player.id);
      None;
    },
    [||],
  );

  <div />;
};
