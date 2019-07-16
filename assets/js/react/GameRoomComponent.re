type action =
  | Tick
  | UpdateTime(int)
  | UpdateSecret(Secret.t)
  | AddTimerId(Js.Global.intervalId);

type state = {
  timerId: option(Js.Global.intervalId),
  timeLeft: option(int),
  secret: option(Secret.t),
};

[@react.component]
let make = (~game: Game.t, ~player: Player.t) => {
  let channel =
    ChannelContextProvider.channelContext
    ->React.useContext
    ->Belt.Option.getExn;

  let (state: state, dispatch: action => unit) =
    React.useReducer(
      (state: state, action: action) =>
        switch (action) {
        | UpdateTime(time) => {...state, timeLeft: Some(time)}
        | AddTimerId(timerId) => {...state, timerId: Some(timerId)}
        | UpdateSecret(secret) => {...state, secret: Some(secret)}
        | Tick =>
          // clear timer when it reaches 0
          switch (state.timeLeft, state.timerId) {
          | (Some(left), Some(timerId)) when left <= 0 =>
            Phoenix.endTimer(channel);
            Js.Global.clearInterval(timerId);
            {...state, timeLeft: Some(0)};
          | _ => {
              ...state,
              timeLeft:
                Belt.Option.map(state.timeLeft, timeLeft => timeLeft - 1),
            }
          }
        },
      {timerId: None, timeLeft: None, secret: None},
    );

  React.useEffect1(
    () => {
      Phoenix.getTimeLeft(channel, timeLeft =>
        dispatch(UpdateTime(timeLeft))
      );

      Phoenix.getSecret(channel, secret => dispatch(UpdateSecret(secret)));
      None;
    },
    [||],
  );

  React.useEffect0(() => {
    let timerId = Js.Global.setInterval(() => dispatch(Tick), 1000);
    dispatch(AddTimerId(timerId));
    Some(() => Js.Global.clearInterval(timerId));
  });

  let padSecondsString = secs => {
    switch (String.length(secs)) {
    | 2 => secs
    | 1 => "0" ++ secs
    | _ => secs
    };
  };

  let secondsToTimeString = (timeLeft: int): string => {
    let mins = string_of_int(timeLeft / 60)->padSecondsString;
    let secs = string_of_int(timeLeft mod 60)->padSecondsString;

    switch (mins, secs) {
    | ("00", "00") => "The game has ended"
    | ("00", secs) => "00:" ++ secs
    | (mins, secs) => mins ++ ":" ++ secs
    };
  };

  let timeLeftComponent = state =>
    switch (state.timeLeft) {
    | Some(timeLeft) =>
      <div> {timeLeft->secondsToTimeString->React.string} </div>
    | None => <div> {React.string("Loading .... ")} </div>
    };

  let displaySecret = secret => {
    (
      switch (secret) {
      | Some(Secret.Spy) => "You are the spy"
      | Some(Secret.Location(location_name)) => location_name
      | None => "Loading..."
      }
    )
    ->React.string;
  };

  let displayPlayers = (game: Game.t) => {
    <div className="flex flex-wrap">
      {{Belt.Array.map(game.players, player =>
          <div className="content-clickable">
            <p className="text-center"> {React.string(player.name)} </p>
          </div>
        )}
       ->React.array}
    </div>;
  };

  let displayLocations = (game: Game.t) => {
    <div className="flex flex-wrap">
      {{Belt.Array.map(game.locations, location =>
          <div className="content-clickable">
            <p className="text-center"> {React.string(location.name)} </p>
          </div>
        )}
       ->React.array}
    </div>;
  };

  <div>
    <div className="mb-1 text-gray-900 font-bold text-3xl">
      {timeLeftComponent(state)}
    </div>
    <div className="font-semibold text-gray-800 mb-12 text-md">
      {displaySecret(state.secret)}
    </div>
    <div className="text-left">
      <h1 className="mb-3 text-gray-700 font-bold uppercase">
        {React.string("Players")}
      </h1>
      <div className="mb-10"> {displayPlayers(game)} </div>
    </div>
    <div className="text-left">
      <h1 className="mb-3 text-gray-700 font-bold uppercase ">
        {React.string("Locations")}
      </h1>
      <div className="mb-4"> {displayLocations(game)} </div>
    </div>
  </div>;
};
