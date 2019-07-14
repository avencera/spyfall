type state = {
  gameId: string,
  player: Player.t,
  game: option(Game.t),
  channel: option(Phx_channel.t),
};

let initialState = (flags: Flags.t): state => {
  gameId: flags.gameId,
  player: {
    ...flags.player,
    role: flags.role,
  },
  game: None,
  channel: None,
};

type action =
  | UpdateChannel(Phx_channel.t)
  | UpdateGame(Game.t);

[@react.component]
let make = (~flags: Js.Json.t) => {
  let flags = Flags.Decode.flags(flags);

  let (state: state, dispatch: action => unit) =
    React.useReducer(
      (state: state, action: action) =>
        switch (action) {
        | UpdateGame(game) => {...state, game: Some(game)}
        | UpdateChannel(channel) => {...state, channel: Some(channel)}
        },
      initialState(flags),
    );

  let updateGame = (game: Game.t) => {
    dispatch(UpdateGame(game));
  };

  React.useEffect1(
    () => {
      let channel =
        Phoenix.joinChannel(state.gameId, state.player.id, updateGame);

      dispatch(UpdateChannel(channel));
      None;
    },
    [||],
  );

  switch (state.game, state.channel) {
  | (None, None)
  | (None, _)
  | (_, None) => <div> {React.string("Loading...")} </div>
  | (Some(game), Some(channel)) =>
    <ChannelContextProvider channel>
      <RoomComponent game player={state.player} />
    </ChannelContextProvider>
  };
};
