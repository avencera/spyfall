type action =
  | Tick
  | UpdateTime(int)
  | UpdateSecret(Secret.t)
  | SelectLocation(Location.t)
  | SelectPlayer(Player.t)
  | ToggleSecretDisplay
  | AddTimerId(Js.Global.intervalId);

type state = {
  timerId: option(Js.Global.intervalId),
  timeLeft: option(int),
  secret: option(Secret.t),
  displaySecret: bool,
  playerSelections: list(Player.t),
  locationSelections: list(Location.t),
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
        | SelectLocation(location) => {
            ...state,
            locationSelections:
              Util.List.toggle(state.locationSelections, location),
          }
        | SelectPlayer(player) => {
            ...state,
            playerSelections:
              Util.List.toggle(state.playerSelections, player),
          }
        | ToggleSecretDisplay => {
            ...state,
            displaySecret: !state.displaySecret,
          }
        },
      {
        timerId: None,
        timeLeft: None,
        secret: None,
        displaySecret: true,
        playerSelections: [],
        locationSelections: [],
      },
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
    let text =
      (
        switch (secret) {
        | Some(Secret.Spy) => "You are the spy"
        | Some(Secret.Location(location_name)) => location_name
        | None => "Loading..."
        }
      )
      ->React.string;

    <div className="flex text-center items-center justify-center text-center">
      <p
        className={
          "ml-4 "
          ++ (state.displaySecret ? "show-hide visible" : "show-hide invisble")
        }>
        text
      </p>
      <span
        onClick={_e => dispatch(ToggleSecretDisplay)}
        className="ml-4 underline text-xs cursor-pointer uppercase font-black flex mt-1 text-gray-800">
        {React.string(state.displaySecret ? "show" : "hide")}
      </span>
    </div>;
  };

  let displayPlayers = (game: Game.t) => {
    <div className="flex flex-wrap">
      {{Belt.Array.mapWithIndex(game.players, (index, player) =>
          <div
            key={player.id}
            className={
              "content-clickable"
              ++ (
                List.mem(player, state.playerSelections)
                  ? " line-through" : ""
              )
            }
            onClick={_e => dispatch(SelectPlayer(player))}>
            <p className="text-center">
              {if (index == 0) {
                 <sup className="pr-1 text-indigo-600 font-semibold">
                   {React.string("1st")}
                 </sup>;
               } else {
                 React.null;
               }}
              {React.string(player.name)}
            </p>
          </div>
        )}
       ->React.array}
    </div>;
  };

  let displayLocations = (game: Game.t) => {
    <div className="flex flex-wrap">
      {{Belt.Array.map(game.locations, location =>
          <div
            className={
              "content-clickable"
              ++ (
                List.mem(location, state.locationSelections)
                  ? " line-through" : ""
              )
            }
            onClick={_e => dispatch(SelectLocation(location))}
            key={location.id}>
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
